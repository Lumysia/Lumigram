import SGLogging
import SGSettingsUI
import SFSafariViewControllerPlus
//
import AccountContext
import Display
import Foundation
import TelegramPresentationData

func sgOpenUrlWithSafariController(
    parsedUrl: URL,
    originalUrl: String,
    context: AccountContext,
    presentationData: PresentationData,
    navigationController: NavigationController?
) {
    if let window = navigationController?.view.window {
        let controller = SFSafariViewControllerPlusDidFinish(url: parsedUrl)
        controller.preferredBarTintColor = presentationData.theme.rootController.navigationBar.opaqueBackgroundColor
        controller.preferredControlTintColor = presentationData.theme.rootController.navigationBar.accentTextColor
        window.rootViewController?.present(controller, animated: true)
    } else {
        context.sharedContext.applicationBindings.openUrl(originalUrl)
    }
}
