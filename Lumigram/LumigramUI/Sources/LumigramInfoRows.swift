import Foundation
import TelegramPresentationData
import LumigramCore

public struct LumigramInfoRow {
    public let label: String
    public let text: String
    public let copyable: Bool

    public init(label: String, text: String, copyable: Bool = true) {
        self.label = label
        self.text = text
        self.copyable = copyable
    }
}

/// Extra rows for a user's profile: the user id, the data center that holds
/// their profile photo, the estimated registration month, and mutual-contact status.
public func lumigramUserInfoRows(userId: Int64, datacenterId: Int?, isMutualContact: Bool, strings: PresentationStrings) -> [LumigramInfoRow] {
    guard LumigramSettings.shared[.showUserInfo] else {
        return []
    }
    let lumigramStrings = LumigramStrings(strings)
    var rows = [LumigramInfoRow(label: lumigramStrings.userId, text: "\(userId)")]
    if let datacenterId {
        rows.append(LumigramInfoRow(label: lumigramStrings.dataCenter, text: "DC \(datacenterId)"))
    }
    if let date = lumigramEstimatedRegistrationDate(userId: userId) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: strings.baseLanguageCode)
        formatter.setLocalizedDateFormatFromTemplate("yMMMM")
        rows.append(LumigramInfoRow(label: lumigramStrings.registered, text: "≈ " + formatter.string(from: date)))
    }
    if isMutualContact {
        rows.append(LumigramInfoRow(label: "", text: lumigramStrings.mutualContact, copyable: false))
    }
    return rows
}
