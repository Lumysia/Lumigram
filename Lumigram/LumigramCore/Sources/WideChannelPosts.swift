import Foundation
import TelegramCore

/// Whether a channel post takes the chat's full width, without the share and
/// summary buttons beside it. Round videos keep their own layout.
public func lumigramWidensChannelPost(_ message: EngineRawMessage) -> Bool {
    guard LumigramSettings.shared[.wideChannelPosts], let channel = message.peers[message.id.peerId] as? TelegramChannel, case .broadcast = channel.info else {
        return false
    }
    return !message.media.contains { ($0 as? TelegramMediaFile)?.isInstantVideo == true }
}
