import Foundation
import SwiftSignalKit
import TelegramCore

/// When a group or channel was created. A basic group carries the date; for a
/// channel it is the date of message 1, the "created" service message, or for
/// a group that became a supergroup, the creation date of the old group that
/// message names. Dates are kept for the session so profile rows can read them.
public enum LumigramChatCreationDate {
    private static let dates = Atomic<[EnginePeer.Id: Int32]>(value: [:])

    public static func cached(_ peerId: EnginePeer.Id) -> Int32? {
        return self.dates.with { $0[peerId] }
    }

    /// `signal`, repeating its latest value once the creation date of the
    /// channel `peerId` is loaded, so a screen built from it shows the date.
    public static func loading<T>(_ signal: Signal<T, NoError>, engine: TelegramEngine, peerId: EnginePeer.Id) -> Signal<T, NoError> {
        guard LumigramSettings.shared[.showUserInfo], peerId.namespace == Namespaces.Peer.CloudChannel, self.cached(peerId) == nil else {
            return signal
        }
        let loaded: Signal<Void, NoError> = engine.messages.getMessagesLoadIfNecessary([EngineMessage.Id(peerId: peerId, namespace: Namespaces.Message.Cloud, id: 1)])
        |> `catch` { _ -> Signal<GetMessagesResult, NoError> in
            return .single(.result([]))
        }
        |> mapToSignal { result -> Signal<Void, NoError> in
            guard case let .result(messages) = result, let message = messages.first.map(EngineMessage.init) else {
                return .complete()
            }
            let _ = self.dates.modify { dates in
                var dates = dates
                dates[peerId] = self.creationDate(message)
                return dates
            }
            return .single(Void())
        }
        return combineLatest(signal, Signal<Void, NoError>.single(Void()) |> then(loaded))
        |> map { value, _ in
            return value
        }
    }

    private static func creationDate(_ message: EngineMessage) -> Int32 {
        for media in message.media {
            if let action = media as? TelegramMediaAction, case let .channelMigratedFromGroup(_, groupId) = action.action, let group = message.peers[groupId] as? TelegramGroup {
                return group.creationDate
            }
        }
        return message.timestamp
    }
}
