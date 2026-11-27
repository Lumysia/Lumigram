import Foundation

/// The relying party for passkeys: the webcredentials domain from the build
/// configuration (Info.plist LGPasskeyRelyingParty). Telegram's own domain only
/// works for Telegram's app, so ours replaces the one the server names.
public var lumigramPasskeyRelyingParty: String? {
    return Bundle.main.object(forInfoDictionaryKey: "LGPasskeyRelyingParty") as? String
}
