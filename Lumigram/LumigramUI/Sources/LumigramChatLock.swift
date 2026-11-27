import Foundation
import UIKit
import LocalAuthentication
import Display
import ContextUI
import AccountContext
import TelegramCore
import TelegramPresentationData
import LumigramCore

/// Face ID (or the device passcode) in front of locked chats. A chat unlocked
/// once stays open until the app goes to the background; then open locked
/// chats are closed, and the app switcher snapshot is covered.
public final class LumigramChatLock {
    public static let shared = LumigramChatLock()

    private var unlocked = Set<EnginePeer.Id>()
    private weak var sharedContext: SharedAccountContext?
    private var cover: UIView?

    private init() {
        let center = NotificationCenter.default
        let _ = center.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.coverIfNeeded()
        }
        let _ = center.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.lockAgain()
        }
        let _ = center.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.cover?.removeFromSuperview()
            self?.cover = nil
        }
    }

    private static var canAuthenticate: Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    private func authenticate(strings: PresentationStrings, completion: @escaping () -> Void) {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: LumigramStrings(strings).unlockChatReason) { success, _ in
            withExtendedLifetime(context) {}
            if success {
                DispatchQueue.main.async(execute: completion)
            }
        }
    }

    /// Whether opening `peerId` has to wait for Face ID. If it does, this asks
    /// and calls `open` once the chat is unlocked.
    public func asksToOpen(_ peerId: EnginePeer.Id, context: AccountContext, open: @escaping () -> Void) -> Bool {
        guard LumigramChatList.locked.contains(peerId, account: context.account.peerId), !self.unlocked.contains(peerId), LumigramChatLock.canAuthenticate else {
            return false
        }
        self.sharedContext = context.sharedContext
        self.authenticate(strings: context.sharedContext.currentPresentationData.with { $0 }.strings) { [weak self] in
            self?.unlocked.insert(peerId)
            open()
        }
        return true
    }

    /// "Lock Chat" or "Remove Chat Lock" for a chat's long-press menu; removing
    /// a lock asks for Face ID first. Forums open their topic list without
    /// going through the chat opener, so they can't be locked.
    public func menuItems(context: AccountContext, peer: EnginePeer) -> [ContextMenuItem] {
        if case let .channel(channel) = peer, channel.isForumOrMonoForum {
            return []
        }
        guard LumigramChatLock.canAuthenticate else {
            return []
        }
        let peerId = peer.id
        let strings = context.sharedContext.currentPresentationData.with { $0 }.strings
        let account = context.account.peerId
        let isLocked = LumigramChatList.locked.contains(peerId, account: account)
        return [.action(ContextMenuActionItem(text: isLocked ? LumigramStrings(strings).unlockChat : LumigramStrings(strings).lockChat, icon: { theme in
            return generateTintedImage(image: UIImage(bundleImageName: "Chat/Context Menu/Lock"), color: theme.contextMenu.primaryColor)
        }, action: { [weak self] _, f in
            f(.default)
            if isLocked {
                self?.authenticate(strings: strings) {
                    LumigramChatList.locked.set(peerId, account: account, included: false)
                }
            } else {
                LumigramChatList.locked.set(peerId, account: account, included: true)
            }
        }))]
    }

    private func coverIfNeeded() {
        guard !self.unlocked.isEmpty, self.cover == nil, let window = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first else {
            return
        }
        let cover = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
        cover.frame = window.bounds
        cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(cover)
        self.cover = cover
    }

    private func lockAgain() {
        if let navigationController = self.sharedContext?.mainWindow?.viewController as? NavigationController {
            let kept = navigationController.viewControllers.filter { controller in
                guard let chat = controller as? ChatController, let peerId = chat.chatLocation.peerId else {
                    return true
                }
                return !self.unlocked.contains(peerId)
            }
            if kept.count != navigationController.viewControllers.count {
                navigationController.setViewControllers(kept, animated: false)
            }
        }
        self.unlocked.removeAll()
    }
}
