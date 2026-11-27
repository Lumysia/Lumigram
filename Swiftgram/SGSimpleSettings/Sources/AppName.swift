import Foundation

/// The app's display name from its Info.plist. Extensions read the containing app's.
public let sgAppName: String = {
    var url = Bundle.main.bundleURL
    if url.pathExtension == "appex" {
        url = url.deletingLastPathComponent().deletingLastPathComponent()
    }
    return Bundle(url: url)?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Swiftgram"
}()
