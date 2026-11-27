import Foundation

/// Whether a push should arrive without sound: pinned-message pushes and
/// pushes for messages that mention or reply to the user, each when turned
/// on. Without Apple's notification-filtering entitlement the notification
/// service can't drop a notification, only silence it.
public func lumigramSilencesNotification(_ payload: [String: Any]) -> Bool {
    if let locKey = payload["loc-key"] as? String, locKey.hasPrefix("PINNED_"), LumigramSettings.shared[.silentPinnedNotifications] {
        return true
    }
    return payload["mention"].map { "\($0)" } == "1" && LumigramSettings.shared[.silentMentionNotifications]
}
