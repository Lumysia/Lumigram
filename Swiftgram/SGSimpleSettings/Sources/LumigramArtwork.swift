import Foundation

// The app icons and app badges offered in settings come from
// Telegram/Telegram-iOS/Resources/LumigramArtwork.json, in picker order, so
// adding or dropping a look changes resources only and recompiles nothing.
// Icons: Telegram/Telegram-iOS/<name>.alticon/<name>@2x.png and @3x.png (every
// LG*.alticon folder is bundled). Badges: an imageset in
// Swiftgram/SGAppBadgeAssets/Images.xcassets/ named after the asset.

public struct LumigramAppIcon: Sendable {
    public let name: String
    /// nil shows the localized "Default" title.
    public let title: String?
    /// A thin border for icons that are near-white.
    public let bordered: Bool
    public let isDefault: Bool
}

public struct LumigramAppBadge: Sendable {
    public let title: String
    public let assetName: String
}

private struct ArtworkFile: Decodable {
    struct Icon: Decodable {
        let name: String
        let title: String?
        let bordered: Bool?
        let isDefault: Bool?

        enum CodingKeys: String, CodingKey {
            case name, title, bordered
            case isDefault = "default"
        }
    }

    struct Badge: Decodable {
        let title: String
        let asset: String
    }

    let icons: [Icon]
    let badges: [Badge]
}

private func loadArtworkFile() -> ArtworkFile? {
    guard let url = Bundle.main.url(forResource: "LumigramArtwork", withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
        return nil
    }
    return try? JSONDecoder().decode(ArtworkFile.self, from: data)
}

public let lumigramAppIcons: [LumigramAppIcon] = (loadArtworkFile()?.icons ?? []).map {
    LumigramAppIcon(name: $0.name, title: $0.title, bordered: $0.bordered ?? false, isDefault: $0.isDefault ?? false)
}

public let lumigramAppBadges: [LumigramAppBadge] = (loadArtworkFile()?.badges.map {
    LumigramAppBadge(title: $0.title, assetName: $0.asset)
}) ?? [LumigramAppBadge(title: "Default", assetName: "Components/AppBadge")]
