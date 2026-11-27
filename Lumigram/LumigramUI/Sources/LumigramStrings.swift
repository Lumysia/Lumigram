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
    public var doubleTapHeader: String { self.text("Double-Tap on a Message", zh: "双击消息") }
    public var doubleTapReaction: String { self.text("Send Reaction", zh: "发送回应") }
    public var doubleTapReply: String { self.text("Reply", zh: "回复") }
    public var doubleTapNothing: String { self.text("Nothing", zh: "无操作") }
    public var chatListHeader: String { self.text("Chat List", zh: "聊天列表") }
    public var hideStories: String { self.text("Hide Stories", zh: "隐藏动态") }
    public var appliesAfterRestart: String { self.text("Applies after the app restarts.", zh: "重启应用后生效。") }
    public var profilesHeader: String { self.text("Profiles", zh: "资料页") }
    public var showUserInfo: String { self.text("ID, Data Center, Registration", zh: "ID、数据中心和注册时间") }
    public var showUserInfoFooter: String {
        self.text(
            "The registration month is estimated on this iPhone from the user ID.",
            zh: "注册月份由本机根据用户 ID 估算。"
        )
    }
    public var userId: String { self.text("ID", zh: "ID") }
    public var dataCenter: String { self.text("Data Center", zh: "数据中心") }
    public var registered: String { self.text("Registered", zh: "注册于") }
    public var filterHeader: String { self.text("Message Filter", zh: "消息过滤") }
    public var filterPlaceholder: String { self.text("One word or phrase per line", zh: "每行一个词或短语") }
    public var filterFooter: String {
        self.text(
            "Incoming messages that contain any of these are hidden in chats.",
            zh: "包含其中任何一项的收到的消息不会在聊天中显示。"
        )
    }
    public var notificationsHeader: String { self.text("Notifications", zh: "通知") }
    public var silentPinnedNotifications: String { self.text("Silent Pinned Message Alerts", zh: "置顶消息通知静音") }
    public var privacyHeader: String { self.text("Privacy", zh: "隐私") }
    public var linkPreviews: String { self.text("Link Previews", zh: "链接预览") }
    public var confirmCalls: String { self.text("Ask Before Calling", zh: "拨打前确认") }
    public var privacyFooter: String {
        self.text(
            "With link previews off, links you send don't get a preview card, so no preview is fetched for them.",
            zh: "关闭链接预览后，你发送的链接不会生成预览卡片，也不会为它们抓取预览。"
        )
    }
    public var confirmCall: String { self.text("Start a voice call?", zh: "要发起语音通话吗？") }
    public var confirmVideoCall: String { self.text("Start a video call?", zh: "要发起视频通话吗？") }
    public var call: String { self.text("Call", zh: "呼叫") }
    public var aboutHeader: String { self.text("About", zh: "关于") }
    public var sourceCode: String { self.text("Source Code", zh: "源代码") }
    public var aboutFooter: String {
        self.text(
            "Lumigram is an unofficial app built on the Telegram API. It is free software under the GNU GPL.",
            zh: "Lumigram 是基于 Telegram API 的非官方应用，以 GNU GPL 发布的自由软件。"
        )
    }
}
