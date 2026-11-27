import Foundation
import LumigramBase

/// Lumigram's own settings: one UserDefaults key per setting in
/// LumigramDefaults.store. Nothing is stored in Postbox.
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
            self.name = LumigramDefaults.key(name)
            self.defaultValue = defaultValue
            super.init()
        }

        public static func ==(lhs: Key, rhs: Key) -> Bool {
            return lhs.name == rhs.name
        }
    }

    public static let shared = LumigramSettings(defaults: LumigramDefaults.store)

    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    public subscript<Value>(key: Key<Value>) -> Value {
        get {
            return self.defaults.object(forKey: key.name) as? Value ?? key.defaultValue
        }
        set {
            self.defaults.set(newValue, forKey: key.name)
        }
    }
}
