import Foundation
import UIKit
import SwiftSignalKit
import TelegramCore

/// The peers an account has blocked, for hiding their messages while
/// `.hideBlockedMessages` is on. Telegram keeps the full list only on the
/// server, so it is loaded when the setting turns on, at launch, and each time
/// the app comes back to the foreground.
public final class LumigramBlockedPeers {
    private static let loaded = Atomic<[EnginePeer.Id: Set<EnginePeer.Id>]>(value: [:])

    /// The peers `account` has blocked, as last loaded.
    public static func ids(account: EnginePeer.Id) -> Set<EnginePeer.Id> {
        return self.loaded.with { $0[account] ?? [] }
    }

    private let account: Account
    private var context: BlockedPeersContext?
    private let stateDisposable = MetaDisposable()
    private var settingDisposable: Disposable?
    private var foregroundObserver: NSObjectProtocol?

    public init(account: Account) {
        self.account = account
        Queue.mainQueue().async { [weak self] in
            guard let self else {
                return
            }
            self.reload()
            let setting = LumigramSettings.Keys.hideBlockedMessages.name
            self.settingDisposable = (LumigramSettings.shared.changes |> filter { $0 == setting } |> deliverOnMainQueue).start(next: { [weak self] _ in
                self?.reload()
            })
            self.foregroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
                self?.reload()
            }
        }
    }

    deinit {
        self.stateDisposable.dispose()
        self.settingDisposable?.dispose()
        if let foregroundObserver = self.foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }
        self.store(nil)
    }

    private func store(_ ids: Set<EnginePeer.Id>?) {
        let account = self.account.peerId
        let _ = LumigramBlockedPeers.loaded.modify { loaded in
            var loaded = loaded
            loaded[account] = ids
            return loaded
        }
    }

    private func reload() {
        guard LumigramSettings.shared[.hideBlockedMessages] else {
            self.context = nil
            self.stateDisposable.set(nil)
            self.store(nil)
            return
        }
        let context = BlockedPeersContext(account: self.account, subject: .blocked)
        self.context = context
        self.stateDisposable.set((context.state |> deliverOnMainQueue).start(next: { [weak self, weak context] state in
            if state.canLoadMore {
                if !state.isLoadingMore {
                    context?.loadMore()
                }
            } else {
                self?.store(Set(state.peers.map(\.peerId)))
            }
        }))
    }
}
