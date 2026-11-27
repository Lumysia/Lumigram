import Foundation
import Display
import AccountContext
import PresentationDataUtils
import LumigramCore

private var callConfirmed = false

/// Asks before a call starts when the setting is on. Returns true when it asked;
/// `call` then runs again after the user confirms and goes through.
public func lumigramAsksBeforeCalling(context: AccountContext, isVideo: Bool, call: @escaping () -> Void) -> Bool {
    if callConfirmed {
        callConfirmed = false
        return false
    }
    guard LumigramSettings.shared[.confirmCalls] else {
        return false
    }
    let presentationData = context.sharedContext.currentPresentationData.with { $0 }
    let strings = LumigramStrings(presentationData.strings)
    context.sharedContext.mainWindow?.present(textAlertController(context: context, title: nil, text: isVideo ? strings.confirmVideoCall : strings.confirmCall, actions: [
        TextAlertAction(type: .genericAction, title: presentationData.strings.Common_Cancel, action: {}),
        TextAlertAction(type: .defaultAction, title: strings.call, action: {
            callConfirmed = true
            call()
        })
    ]), on: .root)
    return true
}
