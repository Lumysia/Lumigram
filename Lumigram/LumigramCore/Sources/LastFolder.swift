import Foundation

/// The chat folder last shown on an account's chat list: 0 for All Chats,
/// otherwise the folder id. Restored at launch when `.rememberFolder` is on.
public func lumigramLastFolderKey(accountId: Int64) -> LumigramSettings.Key<Int> {
    return LumigramSettings.Key<Int>("lastFolder.\(accountId)", default: 0)
}
