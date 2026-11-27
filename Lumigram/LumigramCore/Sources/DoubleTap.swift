import Foundation

public enum LumigramDoubleTapAction: String {
    case reaction
    case reply
    case nothing
}

/// What double-tapping a message does; Telegram's own behaviour is the reaction.
public var lumigramDoubleTapAction: LumigramDoubleTapAction {
    return LumigramDoubleTapAction(rawValue: LumigramSettings.shared[.doubleTapAction]) ?? .reaction
}
