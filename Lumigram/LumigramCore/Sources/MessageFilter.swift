import Foundation
import Postbox

/// Hides incoming messages that contain one of the user's filter words. It only
/// affects what the chat shows; messages it hides after the last one shown are
/// read along with it, so a chat doesn't stay unread because of them.
public struct LumigramMessageFilter {
    private let words: [String]

    public init() {
        self.words = LumigramSettings.shared[.filterWords]
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    public func hides(_ message: Message) -> Bool {
        return message.flags.contains(.Incoming) && self.words.contains { message.text.range(of: $0, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
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
