import Foundation
import TelegramPresentationData

/// Lumigram's own interface text. Telegram's strings come from server language
/// packs that know nothing of these, so each text carries its translations here
/// and follows the app's language.
public struct LumigramStrings {
    private let isChinese: Bool

    public init(_ strings: PresentationStrings) {
        self.isChinese = strings.baseLanguageCode.hasPrefix("zh")
    }

    private func text(_ english: String, zh: String) -> String {
        return self.isChinese ? zh : english
    }

    public var settingsTitle: String { self.text("Lumigram", zh: "Lumigram") }
    public var chatsHeader: String { self.text("Chats", zh: "聊天") }
    public var secondsInTimestamps: String { self.text("Seconds in Message Times", zh: "消息时间显示秒") }
    public var sendWithReturn: String { self.text("Send with Return Key", zh: "回车键发送") }
    public var deletionEffect: String { self.text("Deletion Animation", zh: "删除动画") }
    public var aboutHeader: String { self.text("About", zh: "关于") }
    public var sourceCode: String { self.text("Source Code", zh: "源代码") }
    public var aboutFooter: String {
        self.text(
            "Lumigram is an unofficial app built on the Telegram API. It is free software under the GNU GPL.",
            zh: "Lumigram 是基于 Telegram API 的非官方应用，以 GNU GPL 发布的自由软件。"
        )
    }
}
