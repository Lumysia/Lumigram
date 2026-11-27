import Foundation
import TelegramPresentationData
import ContextUI
import LumigramCore

/// Message menu items that can be hidden. Items are matched by their title,
/// which comes from the same language pack as the menu.
public enum LumigramMenuItem: String, CaseIterable {
    case reply, forward, copyLink, pin, translate, speak, saveMedia, saveToFiles, select, report

    public func titles(_ strings: PresentationStrings) -> [String] {
        switch self {
        case .reply: return [strings.Conversation_ContextMenuReply]
        case .forward: return [strings.Conversation_ContextMenuForward]
        case .copyLink: return [strings.Conversation_ContextMenuCopyLink]
        case .pin: return [strings.Conversation_Pin, strings.Conversation_Unpin]
        case .translate: return [strings.Conversation_ContextMenuTranslate]
        case .speak: return [strings.Conversation_ContextMenuSpeak]
        case .saveMedia: return [strings.Gallery_SaveImage, strings.Gallery_SaveVideo]
        case .saveToFiles: return [strings.Conversation_SaveToFiles]
        case .select: return [strings.Conversation_ContextMenuSelect]
        case .report: return [strings.Conversation_ContextMenuReport]
        }
    }
}

/// The message menu without the items hidden in settings, and without the
/// separators that hiding leaves at the ends or next to each other.
public func lumigramMessageMenu(_ items: [ContextMenuItem], strings: PresentationStrings) -> [ContextMenuItem] {
    let hidden = Set(LumigramSettings.shared[.hiddenMenuItems].compactMap(LumigramMenuItem.init(rawValue:)).flatMap { $0.titles(strings) })
    if hidden.isEmpty {
        return items
    }
    var result: [ContextMenuItem] = []
    for item in items {
        switch item {
        case let .action(action) where hidden.contains(action.text):
            continue
        case .separator:
            if let last = result.last, case .separator = last {
                continue
            }
            if result.isEmpty {
                continue
            }
        default:
            break
        }
        result.append(item)
    }
    if let last = result.last, case .separator = last {
        result.removeLast()
    }
    return result
}
