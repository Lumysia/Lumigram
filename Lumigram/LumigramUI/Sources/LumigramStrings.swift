import Foundation
import TelegramPresentationData
import LumigramBase

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
    public var hideReactions: String { self.text("Hide Reactions", zh: "隐藏回应") }
    public var nextChannelSwipe: String { self.text("Swipe Up to Next Channel", zh: "上滑进入下一个频道") }
    public var aiButton: String { self.text("AI Button in Message Field", zh: "输入框中的 AI 按钮") }
    public var chatListHeader: String { self.text("Chat List", zh: "聊天列表") }
    public var hideStories: String { self.text("Hide Stories", zh: "隐藏动态") }
    public var appliesAfterRestart: String { self.text("Applies after the app restarts.", zh: "重启应用后生效。") }
    public var profilesHeader: String { self.text("Profiles", zh: "资料页") }
    public var showUserInfo: String { self.text("User Info", zh: "用户信息") }
    public var showUserInfoFooter: String {
        self.text(
            "Shows user ID, data center, mutual contact status, and a registration month estimated on this iPhone from the user ID.",
            zh: "显示用户 ID、数据中心、双向联系人状态，以及由本机根据用户 ID 估算的注册月份。"
        )
    }
    public var userId: String { self.text("ID", zh: "ID") }
    public var dataCenter: String { self.text("Data Center", zh: "数据中心") }
    public var registered: String { self.text("Registered", zh: "注册于") }
    public var mutualContact: String { self.text("Mutual Contact", zh: "双向联系人") }
    public var notificationsHeader: String { self.text("Notifications", zh: "通知") }
    public var silentPinnedNotifications: String { self.text("Silent Pinned Message Alerts", zh: "置顶消息通知静音") }
    public var silentMentionNotifications: String { self.text("Silent Mention and Reply Alerts", zh: "提及和回复通知静音") }
    public var notificationsFooter: String {
        self.text(
            "These alerts still appear, without sound. Mentions and replies include those in muted chats.",
            zh: "这些通知仍会显示，只是没有声音。提及和回复也包括已静音聊天中的。"
        )
    }
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
    public var speedBoostHeader: String { self.text("Upload and Download Speed", zh: "上传和下载速度") }
    public func speedBoost(_ boost: LumigramSpeedBoost) -> String {
        switch boost {
        case .off:
            return self.text("Off", zh: "关闭")
        case .medium:
            return self.text("Medium", zh: "中等")
        case .maximum:
            return self.text("Maximum", zh: "最大")
        }
    }
    public var speedBoostFooter: String {
        self.text(
            "Moves files in bigger parts, more at a time, than Telegram's iOS app does. That puts more load on Telegram's servers, so turn it up only when you need it.",
            zh: "比 Telegram 官方 iOS 应用用更大的分块、更多的并发传输文件。这会给 Telegram 的服务器带来更多负载，需要时再开启。"
        )
    }
    public var aboutHeader: String { self.text("About", zh: "关于") }
    public var sourceCode: String { self.text("Source Code", zh: "源代码") }
    public var aboutFooter: String {
        self.text(
            "Lumigram is an unofficial app built on the Telegram API. It is free software under the GNU GPL.",
            zh: "Lumigram 是基于 Telegram API 的非官方应用，以 GNU GPL 发布的自由软件。"
        )
    }
}
