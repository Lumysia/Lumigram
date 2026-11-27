"""Fails when LumigramArtwork.json names an icon or badge that has no files."""
import json
import sys
from pathlib import Path

artwork = json.loads(Path("Telegram/Telegram-iOS/Resources/LumigramArtwork.json").read_text())
missing = []
for icon in artwork["icons"]:
    name = icon["name"]
    for scale in ("2x", "3x"):
        if not Path(f"Telegram/Telegram-iOS/{name}.alticon/{name}@{scale}.png").exists():
            missing.append(f"icon {name}: {name}.alticon/{name}@{scale}.png")
for badge in artwork["badges"]:
    asset = badge["asset"]
    if asset == "Components/AppBadge":
        path = Path("submodules/TelegramUI/Images.xcassets/Components/AppBadge.imageset")
    else:
        path = Path(f"Swiftgram/SGAppBadgeAssets/Images.xcassets/{asset}.imageset")
    if not (path / "Contents.json").exists():
        missing.append(f"badge {badge['title']}: {path}")
for line in missing:
    print(f"::error::Missing artwork for {line}")
print(f"{len(artwork['icons'])} icons, {len(artwork['badges'])} badges, {len(missing)} missing.")
sys.exit(1 if missing else 0)
