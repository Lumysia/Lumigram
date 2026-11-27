import Foundation
import TelegramCore
import TelegramPresentationData
import LumigramCore

public struct LumigramInfoRow {
    public let label: String
    public let text: String
}

private func formatted(_ date: Date, template: String, strings: PresentationStrings) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: strings.baseLanguageCode)
    formatter.setLocalizedDateFormatFromTemplate(template)
    return formatter.string(from: date)
}

/// Extra rows for a user's profile: the user id, the data center that holds
/// their profile photo, and the estimated registration month.
public func lumigramUserInfoRows(userId: Int64, datacenterId: Int?, strings: PresentationStrings) -> [LumigramInfoRow] {
    guard LumigramSettings.shared[.showUserInfo] else {
        return []
    }
    let lumigramStrings = LumigramStrings(strings)
    var rows = [LumigramInfoRow(label: lumigramStrings.userId, text: "\(userId)")]
    if let datacenterId {
        rows.append(LumigramInfoRow(label: lumigramStrings.dataCenter, text: "DC \(datacenterId)"))
    }
    if let date = lumigramEstimatedRegistrationDate(userId: userId) {
        rows.append(LumigramInfoRow(label: lumigramStrings.registered, text: "≈ " + formatted(date, template: "yMMMM", strings: strings)))
    }
    return rows
}

/// Extra rows for a group or channel: its id as bots and the Bot API write it,
/// and when it was created.
public func lumigramChatInfoRows(peer: EnginePeer, strings: PresentationStrings) -> [LumigramInfoRow] {
    guard LumigramSettings.shared[.showUserInfo] else {
        return []
    }
    let lumigramStrings = LumigramStrings(strings)
    let id = peer.id.id._internalGetInt64Value()
    let rows: [LumigramInfoRow]
    let created: Int32?
    switch peer {
    case .channel:
        rows = [LumigramInfoRow(label: lumigramStrings.userId, text: "-100\(id)")]
        created = LumigramChatCreationDate.cached(peer.id)
    case let .legacyGroup(group):
        rows = [LumigramInfoRow(label: lumigramStrings.userId, text: "-\(id)")]
        created = group.creationDate
    default:
        return []
    }
    guard let created, created > 0 else {
        return rows
    }
    let date = Date(timeIntervalSince1970: TimeInterval(created))
    return rows + [LumigramInfoRow(label: lumigramStrings.created, text: formatted(date, template: "yMMMMd", strings: strings))]
}
