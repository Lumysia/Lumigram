"""Writes lumigram-check/BUILD: an ios_build_test over the Swift and Objective-C
libraries whose sources changed since BASE, so a compile error in them fails
within minutes instead of at the end of the app build. ios_build_test applies
the same iOS transition as the app, so the two builds share the Bazel cache.

Usage: compile-check-targets.py BASE [MINIMUM_OS]
Prints the targets; writes nothing and exits 0 when no library changed."""
import re
import subprocess
import sys
from pathlib import Path

base = sys.argv[1]
minimum_os = sys.argv[2] if len(sys.argv) > 2 else "15.0"
library = re.compile(r'(swift_library|objc_library)\(\s*name\s*=\s*"([^"]+)"(.*?)\n\)', re.S)

changed = subprocess.run(
    ["git", "diff", "--name-only", base, "HEAD", "--", "*.swift", "*.m", "*.mm", "*.h", "*BUILD"],
    check=True, capture_output=True, text=True,
).stdout.split()

targets = set()
for name in changed:
    directory = Path(name).parent
    while directory != Path(".") and not (directory / "BUILD").exists():
        directory = directory.parent
    build = directory / "BUILD"
    # The Telegram package is the app itself, built last anyway.
    if not build.exists() or str(directory) == "." or str(directory).startswith(("Tests", "Telegram")):
        continue
    for kind, rule_name, body in library.findall(build.read_text()):
        if "testonly = True" in body or "//visibility:public" not in body:
            continue
        targets.add(f"//{directory}:{rule_name}")

for target in sorted(targets):
    print(target)
if targets:
    Path("lumigram-check").mkdir(exist_ok=True)
    Path("lumigram-check/BUILD").write_text(
        'load("@build_bazel_rules_apple//apple:ios.bzl", "ios_build_test")\n\n'
        "ios_build_test(\n"
        '    name = "check",\n'
        f'    minimum_os_version = "{minimum_os}",\n'
        "    targets = [\n"
        + "".join(f'        "{target}",\n' for target in sorted(targets))
        + "    ],\n)\n"
    )
