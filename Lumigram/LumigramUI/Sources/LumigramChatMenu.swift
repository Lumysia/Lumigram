import Foundation
import UIKit
import Display
import ContextUI
import AccountContext
import TelegramCore
import TelegramPresentationData
import LumigramCore

/// Lumigram's items in a chat's long-press menu in the chat list.
public func lumigramChatMenuItems(context: AccountContext, peer: EnginePeer) -> [ContextMenuItem] {
    return LumigramChatLock.shared.menuItems(context: context, peer: peer) + silentMentionsMenuItems(context: context, peer: peer)
}

/// "Silence Mentions" for a group: its mention and reply alerts come
/// without sound.
private func silentMentionsMenuItems(context: AccountContext, peer: EnginePeer) -> [ContextMenuItem] {
    switch peer {
    case .legacyGroup:
        break
    case let .channel(channel):
        guard case .group = channel.info else {
            return []
        }
    default:
        return []
    }
    let strings = LumigramStrings(context.sharedContext.currentPresentationData.with { $0 }.strings)
    let account = context.account.peerId
    let isSilenced = LumigramChatList.silentMentions.contains(peer.id, account: account)
    return [.action(ContextMenuActionItem(text: isSilenced ? strings.unsilenceMentions : strings.silenceMentions, icon: { theme in
        return generateTintedImage(image: UIImage(bundleImageName: "Chat/Context Menu/Mention"), color: theme.contextMenu.primaryColor)
    }, action: { _, f in
        f(.default)
        LumigramChatList.silentMentions.set(peer.id, account: account, included: !isSilenced)
    }))]
}
