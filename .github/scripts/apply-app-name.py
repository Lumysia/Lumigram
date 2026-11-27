"""Puts the configured app name into the bundled texts that mean this app
rather than the Telegram service: permission prompts, "set Telegram to ON"
hints and the first intro page.

Usage: apply-app-name.py CONFIGURATION_JSON"""
import json
import re
import sys
from pathlib import Path

name = json.loads(Path(sys.argv[1]).read_text())["app_name"]
app_keys = re.compile(
    r"NSLocation\w*UsageDescription|AccessDenied\.\w+|Contacts\.AccessDenied\w*|Contacts\.PermissionsText"
    r"|Tour\.Title1|Passcode\.AppLockedAlert|Share\.Auth\w+|Intents\.ErrorLockedText|ChatImportActivity\.OpenApp"
    r"|Media\.LimitedAccessText|Attachment\.(LimitedMediaAccessText|CameraAccessText)"
    r"|Story\.Camera\.AccessPlaceholderTitle|ShareFileTip\.Text|Conversation\.FileHowToText"
)
entry = re.compile(r'^("(?P<key>[^"]+)"\s*=\s*")(?P<value>(?:[^"\\]|\\.)*)(";)', re.M)


def rename(match):
    if not app_keys.fullmatch(match["key"]):
        return match[0]
    return match[1] + match["value"].replace("Telegram", name) + match[4]


files = [
    *Path("Telegram/Telegram-iOS").glob("*.lproj/InfoPlist.strings"),
    Path("Telegram/Telegram-iOS/en.lproj/Localizable.strings"),
]
changed = 0
for path in files:
    text = path.read_text(encoding="utf-8")
    updated = entry.sub(rename, text)
    changed += sum(a != b for a, b in zip(text.splitlines(), updated.splitlines()))
    path.write_text(updated, encoding="utf-8")
print(f"App name '{name}' written into {changed} strings.")
