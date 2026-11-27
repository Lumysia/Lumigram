import Foundation

/// The app's display name from its Info.plist. Extensions read the containing app's.
public let sgAppName: String = {
    var url = Bundle.main.bundleURL
    if url.pathExtension == "appex" {
        url = url.deletingLastPathComponent().deletingLastPathComponent()
    }
    return Bundle(url: url)?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Swiftgram"
}()

/// The relying party for passkeys, from LGPasskeyRelyingParty in the app's
/// Info.plist. It is set only when the app's entitlements list a
/// webcredentials domain; without one, passkeys can't work and stay hidden.
public let lumigramPasskeyRelyingParty: String? = {
    var url = Bundle.main.bundleURL
    if url.pathExtension == "appex" { url = url.deletingLastPathComponent().deletingLastPathComponent() }
    guard let value = Bundle(url: url)?.object(forInfoDictionaryKey: "LGPasskeyRelyingParty") as? String, !value.isEmpty else {
        return nil
    }
    return value
}()
