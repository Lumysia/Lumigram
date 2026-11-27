import Foundation

// The app icons and app badges offered in settings, in picker order. This is
// the only list: add or drop a look here and add or delete its files.
// Icons: Telegram/Telegram-iOS/<name>.alticon/<name>@2x.png and @3x.png (every
// LG*.alticon folder is bundled). Badges: an imageset in
// Swiftgram/SGAppBadgeAssets/Images.xcassets/ named after the asset.

public struct LumigramAppIcon {
    public let name: String
    /// nil shows the localized "Default" title.
    public let title: String?
    /// A thin border for icons that are near-white.
    public let bordered: Bool
    public let isDefault: Bool

    init(_ name: String, _ title: String?, bordered: Bool = false, isDefault: Bool = false) {
        self.name = name
        self.title = title
        self.bordered = bordered
        self.isDefault = isDefault
    }
}

public struct LumigramAppBadge {
    public let title: String
    public let assetName: String
}

public let lumigramAppIcons: [LumigramAppIcon] = [
    LumigramAppIcon("LGDefault", nil, isDefault: true),
    LumigramAppIcon("LGLight", "Light", bordered: true),
    LumigramAppIcon("LGDark", "Dark"),
    LumigramAppIcon("LGTrans", "Trans"),
    LumigramAppIcon("LGPride", "Pride"),
    LumigramAppIcon("LGBisexual", "Bisexual"),
    LumigramAppIcon("LGLesbian", "Lesbian"),
    LumigramAppIcon("LGNonbinary", "Nonbinary"),
    LumigramAppIcon("LGPansexual", "Pansexual"),
]

public let lumigramAppBadges: [LumigramAppBadge] = [
    LumigramAppBadge(title: "Default", assetName: "Components/AppBadge"),
    LumigramAppBadge(title: "Light", assetName: "LightAppBadge"),
    LumigramAppBadge(title: "Dark", assetName: "DarkAppBadge"),
    LumigramAppBadge(title: "Trans", assetName: "TransAppBadge"),
    LumigramAppBadge(title: "Pride", assetName: "PrideAppBadge"),
    LumigramAppBadge(title: "Bisexual", assetName: "BisexualAppBadge"),
    LumigramAppBadge(title: "Lesbian", assetName: "LesbianAppBadge"),
    LumigramAppBadge(title: "Nonbinary", assetName: "NonbinaryAppBadge"),
    LumigramAppBadge(title: "Pansexual", assetName: "PansexualAppBadge"),
]
