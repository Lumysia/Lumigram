import Foundation
import Postbox

/// Hides incoming messages that contain one of the user's filter words. It only
/// affects what the chat shows; messages it hides after the last one shown are
/// read along with it, so a chat doesn't stay unread because of them.
///
/// A line written as /pattern/ is a case-insensitive regular expression; any
/// other line matches as plain text.
public struct LumigramMessageFilter {
    private let words: [String]
    private let patterns: [NSRegularExpression]

    public init() {
        let lines = LumigramSettings.shared[.filterWords]
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let isPattern: (String) -> Bool = { $0.count > 2 && $0.hasPrefix("/") && $0.hasSuffix("/") }
        self.words = lines.filter { !isPattern($0) }
        self.patterns = lines.filter(isPattern).compactMap { try? NSRegularExpression(pattern: String($0.dropFirst().dropLast()), options: .caseInsensitive) }
    }

    public func hides(_ message: Message) -> Bool {
        guard message.flags.contains(.Incoming), !message.text.isEmpty else {
            return false
        }
        let text = message.text
        return self.words.contains { text.range(of: $0, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
            || self.patterns.contains { $0.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil }
    }

    /// The index to read up to when `index` is the newest message shown and
    /// `messages` is the whole loaded history.
    public func readIndex(after index: MessageIndex, in messages: [Message]) -> MessageIndex {
        let later = messages.filter { $0.index > index }
        guard let last = later.last, later.allSatisfy(self.hides) else {
            return index
        }
        return last.index
    }
}
