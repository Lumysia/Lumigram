import Foundation

/// Where Lumigram's settings live: the app group's UserDefaults, so the app and
/// its extensions read the same values. Telegram's lowest modules read values
/// from here directly, so this module stays small and rarely changes.
public enum LumigramDefaults {
    public static let store: UserDefaults = {
        var bundleId = Bundle.main.bundleIdentifier ?? ""
        if Bundle.main.bundleURL.pathExtension == "appex", let dot = bundleId.lastIndex(of: ".") {
            bundleId = String(bundleId[..<dot])
        }
        return UserDefaults(suiteName: "group.\(bundleId)") ?? .standard
    }()

    public static func key(_ name: String) -> String {
        return "lumigram." + name
    }
}
