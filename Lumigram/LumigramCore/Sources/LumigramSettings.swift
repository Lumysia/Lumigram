import Foundation
import SwiftSignalKit

/// Lumigram's own settings: one UserDefaults key per setting, kept in the app
/// group so the app and its extensions read the same values. Nothing is stored
/// in Postbox.
public final class LumigramSettings {
    /// Keys are declared as static members of Keys (Keys.swift), so call sites
    /// can write `LumigramSettings.shared[.name]`.
    public class Keys {
        fileprivate init() {
        }
    }

    public final class Key<Value>: Keys, Equatable {
        public let name: String
        public let defaultValue: Value

        public init(_ name: String, default defaultValue: Value) {
            self.name = "lumigram." + name
            self.defaultValue = defaultValue
            super.init()
        }

        public static func ==(lhs: Key, rhs: Key) -> Bool {
            return lhs.name == rhs.name
        }
    }

    public static let shared = LumigramSettings(defaults: LumigramSettings.appGroupDefaults())

    private let defaults: UserDefaults
    private let changed = ValuePipe<String>()

    /// Emits the name of each key whose value is set.
    public var changes: Signal<String, NoError> {
        return self.changed.signal()
    }

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    public subscript<Value>(key: Key<Value>) -> Value {
        get {
            return self.defaults.object(forKey: key.name) as? Value ?? key.defaultValue
        }
        set {
            self.defaults.set(newValue, forKey: key.name)
            self.changed.putNext(key.name)
        }
    }

    private static func appGroupDefaults() -> UserDefaults {
        var bundleId = Bundle.main.bundleIdentifier ?? ""
        if Bundle.main.bundleURL.pathExtension == "appex", let dot = bundleId.lastIndex(of: ".") {
            bundleId = String(bundleId[..<dot])
        }
        return UserDefaults(suiteName: "group.\(bundleId)") ?? .standard
    }
}
