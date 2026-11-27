"""Checks a built IPA for user-visible "Swiftgram": bundled strings, Siri phrase
examples, Info.plist names and usage descriptions fail the check; text phrases
inside the binaries are listed for review."""
import plistlib
import re
import sys
import zipfile

word = re.compile(rb"\bSwiftgram\b")
phrase = re.compile(rb"[ -~]{0,40}\bSwiftgram\b[ -~]{0,40}")
visible_keys = ("CFBundleDisplayName", "CFBundleName", "NSExtensionPointName")


def strings_values(data):
    try:
        loaded = plistlib.loads(data)
        if isinstance(loaded, dict):
            return [str(v).encode() for v in loaded.values()]
    except Exception:
        pass
    for encoding in ("utf-16", "utf-8"):
        try:
            return [data.decode(encoding).encode()]
        except UnicodeDecodeError:
            continue
    return [data]


failures, phrases = [], set()
with zipfile.ZipFile(sys.argv[1]) as ipa:
    for name in ipa.namelist():
        if name.endswith(".strings"):
            for value in strings_values(ipa.read(name)):
                if word.search(value):
                    failures.append(f"{name}: {value[:80]!r}")
        elif name.endswith("Info.plist"):
            info = plistlib.loads(ipa.read(name))
            for key, value in info.items():
                if (key in visible_keys or key.endswith("UsageDescription")) and word.search(str(value).encode()):
                    failures.append(f"{name}: {key} = {value}")
        elif ".lproj/" in name and name.endswith(".plist"):
            if word.search(ipa.read(name)):
                failures.append(f"{name}: contains Swiftgram")
        elif "/Frameworks/" in name or name.count("/") == 2:
            data = ipa.read(name)
            if data[:4] in (b"\xcf\xfa\xed\xfe", b"\xca\xfe\xba\xbe"):
                for match in phrase.findall(data):
                    text = match.decode("ascii").strip()
                    if " " in text:
                        phrases.add(text)

for line in failures:
    print(f"::error::{line}")
print(f"{len(failures)} user-visible 'Swiftgram' in strings and Info.plist files.")
print("Phrases with 'Swiftgram' still inside the binaries (review):")
for text in sorted(phrases):
    print("  " + text)
sys.exit(1 if failures else 0)
