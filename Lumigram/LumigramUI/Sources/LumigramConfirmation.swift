import Foundation
import Display
import AccountContext
import PresentationDataUtils
import LumigramCore

private var confirmed = Set<String>()

/// When the setting `key` is on, asks first and returns true; once the user
/// confirms, `proceed` runs and this time the call goes through.
private func asks(_ key: LumigramSettings.Key<Bool>, context: AccountContext, text: String, action: String, proceed: @escaping () -> Void) -> Bool {
    if confirmed.remove(key.name) != nil {
        return false
    }
    guard LumigramSettings.shared[key] else {
        return false
    }
    let presentationData = context.sharedContext.currentPresentationData.with { $0 }
    context.sharedContext.mainWindow?.present(textAlertController(context: context, title: nil, text: text, actions: [
        TextAlertAction(type: .genericAction, title: presentationData.strings.Common_Cancel, action: {}),
        TextAlertAction(type: .defaultAction, title: action, action: {
            confirmed.insert(key.name)
            proceed()
        })
    ]), on: .root)
    return true
}

public func lumigramAsksBeforeCalling(context: AccountContext, isVideo: Bool, call: @escaping () -> Void) -> Bool {
    let strings = LumigramStrings(context.sharedContext.currentPresentationData.with { $0 }.strings)
    return asks(.confirmCalls, context: context, text: isVideo ? strings.confirmVideoCall : strings.confirmCall, action: strings.call, proceed: call)
}

public func lumigramAsksBeforeOpeningStories(context: AccountContext, open: @escaping () -> Void) -> Bool {
    let strings = LumigramStrings(context.sharedContext.currentPresentationData.with { $0 }.strings)
    return asks(.confirmStories, context: context, text: strings.confirmStories, action: strings.openStories, proceed: open)
}
