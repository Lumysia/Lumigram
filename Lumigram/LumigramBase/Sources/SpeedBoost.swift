import Foundation

/// Faster file transfers on the MTProto engine: downloads of files over 1 MB use
/// bigger parts with more of them in flight, and uploads use the larger, parallel
/// parts Telegram itself uses for chat imports.
public enum LumigramSpeedBoost: Int, CaseIterable {
    case off
    case medium
    case maximum

    public static let settingName = "speedBoost"

    public static var current: LumigramSpeedBoost {
        return LumigramSpeedBoost(rawValue: LumigramDefaults.store.integer(forKey: LumigramDefaults.key(settingName))) ?? .off
    }

    public static func downloadPartSize(_ defaultSize: Int64, fileSize: Int64?) -> Int64 {
        // Bigger parts make small files slower: they arrive in one request either way.
        if let fileSize, fileSize <= 1024 * 1024 {
            return defaultSize
        }
        switch current {
        case .off:
            return defaultSize
        case .medium:
            return 512 * 1024
        case .maximum:
            return 1024 * 1024
        }
    }

    public static func pendingParts(_ defaultCount: Int) -> Int {
        switch current {
        case .off:
            return defaultCount
        case .medium:
            return 8
        case .maximum:
            return 12
        }
    }

    public static var boostsUploads: Bool {
        return current != .off
    }
}
