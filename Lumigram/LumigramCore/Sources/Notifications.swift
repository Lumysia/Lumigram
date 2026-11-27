import Foundation
import TelegramCore

/// Whether a push should arrive without sound: pinned-message pushes, and
/// pushes for messages that mention or reply to the user, everywhere or in
/// the chats picked for it. Without Apple's notification-filtering
/// entitlement the notification service can't drop a notification, only
/// silence it.
public func lumigramSilencesNotification(_ payload: [String: Any], peerId: EnginePeer.Id, account: EnginePeer.Id) -> Bool {
    if let locKey = payload["loc-key"] as? String, locKey.hasPrefix("PINNED_"), LumigramSettings.shared[.silentPinnedNotifications] {
        return true
    }
    guard payload["mention"].map({ "\($0)" }) == "1" else {
        return false
    }
    return LumigramSettings.shared[.silentMentionNotifications] || LumigramChatList.silentMentions.contains(peerId, account: account)
}
