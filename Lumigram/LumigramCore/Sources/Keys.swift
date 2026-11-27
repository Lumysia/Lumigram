import Foundation

public extension LumigramSettings.Keys {
    static let secondsInTimestamps = LumigramSettings.Key<Bool>("secondsInTimestamps", default: false)
    static let sendWithReturn = LumigramSettings.Key<Bool>("sendWithReturn", default: false)
    static let deletionEffect = LumigramSettings.Key<Bool>("deletionEffect", default: true)
}
