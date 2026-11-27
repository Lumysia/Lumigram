import Foundation

/// Whether chats can be translated on the device with Apple's Translation
/// framework. Lumigram offers this to every account, Premium or not.
public var lumigramTranslatesOnDevice: Bool {
    if #available(iOS 18.0, *) {
        return true
    } else {
        return false
    }
}
