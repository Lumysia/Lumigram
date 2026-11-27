import Foundation

public extension LumigramSettings.Keys {
    static let secondsInTimestamps = LumigramSettings.Key<Bool>("secondsInTimestamps", default: false)
    static let sendWithReturn = LumigramSettings.Key<Bool>("sendWithReturn", default: false)
    static let deletionEffect = LumigramSettings.Key<Bool>("deletionEffect", default: true)
    static let doubleTapAction = LumigramSettings.Key<String>("doubleTapAction", default: LumigramDoubleTapAction.reaction.rawValue)
    static let hiddenMenuItems = LumigramSettings.Key<[String]>("hiddenMenuItems", default: [])
    static let stickerSize = LumigramSettings.Key<String>("stickerSize", default: "default")
    static let hideStories = LumigramSettings.Key<Bool>("hideStories", default: false)
    static let confirmStories = LumigramSettings.Key<Bool>("confirmStories", default: false)
    static let tabTitles = LumigramSettings.Key<Bool>("tabTitles", default: true)
    static let compactTabs = LumigramSettings.Key<Bool>("compactTabs", default: false)
    static let rememberFolder = LumigramSettings.Key<Bool>("rememberFolder", default: true)
    static let showUserInfo = LumigramSettings.Key<Bool>("showUserInfo", default: true)
    static let filterWords = LumigramSettings.Key<[String]>("filterWords", default: [])
    static let silentPinnedNotifications = LumigramSettings.Key<Bool>("silentPinnedNotifications", default: false)
    static let linkPreviews = LumigramSettings.Key<Bool>("linkPreviews", default: false)
    static let confirmCalls = LumigramSettings.Key<Bool>("confirmCalls", default: true)
}
