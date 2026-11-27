import Foundation
import LumigramBase

public extension LumigramSettings.Keys {
    static let secondsInTimestamps = LumigramSettings.Key<Bool>("secondsInTimestamps", default: false)
    static let sendWithReturn = LumigramSettings.Key<Bool>("sendWithReturn", default: false)
    static let deletionEffect = LumigramSettings.Key<Bool>("deletionEffect", default: true)
    static let hideStories = LumigramSettings.Key<Bool>("hideStories", default: false)
    static let showUserInfo = LumigramSettings.Key<Bool>("showUserInfo", default: true)
    static let silentPinnedNotifications = LumigramSettings.Key<Bool>("silentPinnedNotifications", default: false)
    static let silentMentionNotifications = LumigramSettings.Key<Bool>("silentMentionNotifications", default: false)
    static let linkPreviews = LumigramSettings.Key<Bool>("linkPreviews", default: false)
    static let confirmCalls = LumigramSettings.Key<Bool>("confirmCalls", default: true)
    static let speedBoost = LumigramSettings.Key<Int>(LumigramSpeedBoost.settingName, default: LumigramSpeedBoost.off.rawValue)
}
