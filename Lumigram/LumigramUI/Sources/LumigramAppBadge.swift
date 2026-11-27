import UIKit
import Display

/// Shows the badge at the top of the window that matches the app icon: icon
/// `<Name>` has the image `Components/<Name>Badge`, and the main icon keeps
/// `Components/AppBadge`.
public func lumigramUpdateAppBadge(_ badgeView: UIImageView, iconName: String?) {
    DispatchQueue.main.async {
        badgeView.image = iconName.flatMap { UIImage(bundleImageName: "Components/\($0)Badge") } ?? UIImage(bundleImageName: "Components/AppBadge")
    }
}
