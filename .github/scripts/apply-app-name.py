"""Puts the configured app name into the bundled strings and Siri phrase examples
in place of "Swiftgram"."""
import json
import re
import sys
from pathlib import Path

name = json.loads(Path(sys.argv[1]).read_text())["app_name"]
word = re.compile(r"\bSwiftgram\b")
# Italian Siri examples add a pronunciation hint: "Swiftgram (Swiftgramma)".
hint = re.compile(r" \(Swiftgramma\)")
files = [
    *Path("Telegram/Telegram-iOS").glob("*.lproj/*.strings"),
    *Path("Telegram/Telegram-iOS").glob("*.lproj/AppIntentVocabulary.plist"),
    *Path("Swiftgram/SGStrings/Strings").glob("*.lproj/SGLocalizable.strings"),
]
changed = 0
for path in files:
    text = path.read_text(encoding="utf-8")
    updated = word.sub(name, hint.sub("", text))
    if updated != text:
        path.write_text(updated, encoding="utf-8")
        changed += 1
print(f"App name '{name}' written into {changed} strings and plist files.")
