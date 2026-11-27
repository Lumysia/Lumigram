import Foundation
import TelegramCore

/// Chats picked per account for one setting, such as the chats locked with
/// Face ID. Kept in the app group, so the notification service reads them too.
public struct LumigramChatList {
    public static let locked = LumigramChatList(key: .lockedChats)
    public static let silentMentions = LumigramChatList(key: .silentMentionChats)

    private let key: LumigramSettings.Key<[String]>

    private func entry(_ peerId: EnginePeer.Id, account: EnginePeer.Id) -> String {
        return "\(account.toInt64()):\(peerId.toInt64())"
    }

    public func contains(_ peerId: EnginePeer.Id, account: EnginePeer.Id) -> Bool {
        return LumigramSettings.shared[self.key].contains(self.entry(peerId, account: account))
    }

    public func set(_ peerId: EnginePeer.Id, account: EnginePeer.Id, included: Bool) {
        let entry = self.entry(peerId, account: account)
        LumigramSettings.shared[self.key] = LumigramSettings.shared[self.key].filter { $0 != entry } + (included ? [entry] : [])
    }
}
