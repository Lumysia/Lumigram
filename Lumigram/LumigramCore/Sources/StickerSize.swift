import Foundation

/// How large stickers are drawn in chats, as a share of Telegram's size.
public var lumigramStickerScale: CGFloat {
    switch LumigramSettings.shared[.stickerSize] {
    case "small":
        return 0.6
    case "medium":
        return 0.8
    default:
        return 1.0
    }
}
