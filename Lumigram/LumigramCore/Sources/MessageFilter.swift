import Foundation
import TelegramCore

/// Hides incoming messages that contain one of the user's filter words or come
/// from a blocked peer, and reactions when they are turned off. It only
/// affects what the chat shows; messages it hides after the last one shown
/// are read along with it, so a chat doesn't stay unread because of them.
///
/// A line written as /pattern/ is a case-insensitive regular expression; any
/// other line matches as plain text.
public struct LumigramMessageFilter {
    private let words: [String]
    private let patterns: [NSRegularExpression]
    private let blocked: Set<EnginePeer.Id>
    private let hidesReactions = LumigramSettings.shared[.hideReactions]

    public init(account: EnginePeer.Id) {
        self.blocked = LumigramBlockedPeers.ids(account: account)
        let lines = LumigramSettings.shared[.filterWords]
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let isPattern: (String) -> Bool = { $0.count > 2 && $0.hasPrefix("/") && $0.hasSuffix("/") }
        self.words = lines.filter { !isPattern($0) }
        self.patterns = lines.filter(isPattern).compactMap { try? NSRegularExpression(pattern: String($0.dropFirst().dropLast()), options: .caseInsensitive) }
    }

    public func hides(_ message: EngineMessage) -> Bool {
        guard message.flags.contains(.Incoming) else {
            return false
        }
        if let author = message.author?.id, self.blocked.contains(author) {
            return true
        }
        let text = message.text
        return self.words.contains { text.range(of: $0, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
            || self.patterns.contains { $0.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil }
    }

    /// The message as the chat shows it. Hidden reactions keep an empty
    /// attribute, so the reactions it marks unseen are still marked seen.
    public func shown(_ message: EngineRawMessage) -> EngineRawMessage {
        guard self.hidesReactions, message.attributes.contains(where: { $0 is ReactionsMessageAttribute || $0 is PendingReactionsMessageAttribute }) else {
            return message
        }
        return message.withUpdatedAttributes(message.attributes.compactMap { attribute -> EngineMessage.Attribute? in
            if attribute is PendingReactionsMessageAttribute {
                return nil
            }
            if let reactions = attribute as? ReactionsMessageAttribute, !reactions.isTags {
                return ReactionsMessageAttribute(canViewList: false, isTags: false, reactions: [], recentPeers: reactions.recentPeers, topPeers: [])
            }
            return attribute
        })
    }

    /// The index to read up to when `index` is the newest message shown and
    /// `messages` is the whole loaded history.
    public func readIndex(after index: EngineMessage.Index, in messages: [EngineMessage]) -> EngineMessage.Index {
        let later = messages.filter { $0.index > index }
        guard let last = later.last, later.allSatisfy(self.hides) else {
            return index
        }
        return last.index
    }
}
