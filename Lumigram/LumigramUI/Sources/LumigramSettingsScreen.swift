import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramPresentationData
import ItemListUI
import AccountContext
import PresentationDataUtils
import LumigramCore

private let sourceCodeUrl = "https://github.com/Lumysia/Lumigram"

private struct Section {
    enum Row {
        case toggle(String, LumigramSettings.Key<Bool>)
        case shown(String, unlessIn: LumigramSettings.Key<[String]>, id: String)
        case lines(placeholder: String, LumigramSettings.Key<[String]>)
        case option(String, LumigramSettings.Key<String>, value: String)
        case link(String, url: String)
    }

    let header: String?
    let rows: [Row]
    let footer: String?
}

/// Every Lumigram setting, in screen order. A feature adds its rows here.
private func sections(_ strings: LumigramStrings, _ presentationStrings: PresentationStrings) -> [Section] {
    return [
        Section(header: strings.chatsHeader, rows: [
            .toggle(strings.secondsInTimestamps, .secondsInTimestamps),
            .toggle(strings.sendWithReturn, .sendWithReturn),
            .toggle(strings.deletionEffect, .deletionEffect),
            .toggle(strings.hideReactions, .hideReactions),
            .toggle(strings.wideChannelPosts, .wideChannelPosts),
        ], footer: nil),
        Section(header: strings.doubleTapHeader, rows: [
            .option(strings.doubleTapReaction, .doubleTapAction, value: LumigramDoubleTapAction.reaction.rawValue),
            .option(strings.doubleTapReply, .doubleTapAction, value: LumigramDoubleTapAction.reply.rawValue),
            .option(strings.doubleTapNothing, .doubleTapAction, value: LumigramDoubleTapAction.nothing.rawValue),
        ], footer: nil),
        Section(header: strings.messageMenuHeader, rows: LumigramMenuItem.allCases.map { item in
            Section.Row.shown(item.titles(presentationStrings)[0], unlessIn: .hiddenMenuItems, id: item.rawValue)
        }, footer: nil),
        Section(header: strings.stickerSizeHeader, rows: [
            .option(strings.stickerSizeDefault, .stickerSize, value: "default"),
            .option(strings.stickerSizeMedium, .stickerSize, value: "medium"),
            .option(strings.stickerSizeSmall, .stickerSize, value: "small"),
        ], footer: nil),
        Section(header: strings.chatListHeader, rows: [
            .toggle(strings.rememberFolder, .rememberFolder),
            .toggle(strings.compactTabs, .compactTabs),
            .toggle(strings.tabTitles, .tabTitles),
            .toggle(strings.hideStories, .hideStories),
            .toggle(strings.confirmStoriesToggle, .confirmStories),
        ], footer: strings.appliesAfterRestart),
        Section(header: strings.profilesHeader, rows: [.toggle(strings.showUserInfo, .showUserInfo)], footer: strings.showUserInfoFooter),
        Section(header: strings.filterHeader, rows: [
            .lines(placeholder: strings.filterPlaceholder, .filterWords),
            .toggle(strings.hideBlockedMessages, .hideBlockedMessages),
        ], footer: strings.filterFooter),
        Section(header: strings.notificationsHeader, rows: [
            .toggle(strings.silentPinnedNotifications, .silentPinnedNotifications),
            .toggle(strings.silentMentionNotifications, .silentMentionNotifications),
        ], footer: strings.notificationsFooter),
        Section(header: strings.privacyHeader, rows: [
            .toggle(strings.linkPreviews, .linkPreviews),
            .toggle(strings.confirmCalls, .confirmCalls),
        ], footer: strings.privacyFooter),
        Section(header: strings.aboutHeader, rows: [.link(strings.sourceCode, url: sourceCodeUrl)], footer: strings.aboutFooter),
    ]
}

private struct Entry: ItemListNodeEntry {
    enum Content: Equatable {
        case header(String)
        case toggle(String, LumigramSettings.Key<Bool>, Bool)
        case shown(String, LumigramSettings.Key<[String]>, id: String, Bool)
        case lines(placeholder: String, LumigramSettings.Key<[String]>, String)
        case option(String, LumigramSettings.Key<String>, value: String, isSelected: Bool)
        case link(String, url: String)
        case footer(String)
    }

    let section: ItemListSectionId
    let stableId: Int
    let content: Content

    static func <(lhs: Entry, rhs: Entry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let openUrl = arguments as! ((String) -> Void)
        switch self.content {
        case let .header(text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .toggle(title, key, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                LumigramSettings.shared[key] = value
            })
        case let .shown(title, key, id, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                LumigramSettings.shared[key] = LumigramSettings.shared[key].filter { $0 != id } + (value ? [] : [id])
            })
        case let .lines(placeholder, key, text):
            return ItemListMultilineInputItem(presentationData: presentationData, systemStyle: .glass, text: text, placeholder: placeholder, maxLength: nil, sectionId: self.section, style: .blocks, capitalization: false, autocorrection: false, textUpdated: { text in
                LumigramSettings.shared[key] = text.components(separatedBy: "\n")
            })
        case let .option(title, key, value, isSelected):
            return ItemListCheckboxItem(presentationData: presentationData, systemStyle: .glass, title: title, style: .left, checked: isSelected, zeroSeparatorInsets: false, sectionId: self.section, action: {
                LumigramSettings.shared[key] = value
            })
        case let .link(title, url):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: title, label: "", sectionId: self.section, style: .blocks, action: {
                openUrl(url)
            })
        case let .footer(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        }
    }
}

private func entries(_ sections: [Section]) -> [Entry] {
    var entries: [Entry] = []
    for (index, section) in sections.enumerated() {
        let id = ItemListSectionId(index)
        func append(_ content: Entry.Content) {
            entries.append(Entry(section: id, stableId: entries.count, content: content))
        }
        if let header = section.header {
            append(.header(header))
        }
        for row in section.rows {
            switch row {
            case let .toggle(title, key):
                append(.toggle(title, key, LumigramSettings.shared[key]))
            case let .shown(title, key, id):
                append(.shown(title, key, id: id, !LumigramSettings.shared[key].contains(id)))
            case let .lines(placeholder, key):
                append(.lines(placeholder: placeholder, key, LumigramSettings.shared[key].joined(separator: "\n")))
            case let .option(title, key, value):
                append(.option(title, key, value: value, isSelected: LumigramSettings.shared[key] == value))
            case let .link(title, url):
                append(.link(title, url: url))
            }
        }
        if let footer = section.footer {
            append(.footer(footer))
        }
    }
    return entries
}

public func lumigramSettingsScreen(context: AccountContext) -> ViewController {
    let openUrl: (String) -> Void = { url in
        context.sharedContext.applicationBindings.openUrl(url)
    }
    let settingsChanged: Signal<Void, NoError> = .single(Void()) |> then(LumigramSettings.shared.changes |> map { _ in })
    let signal = combineLatest(queue: .mainQueue(), context.sharedContext.presentationData, settingsChanged)
    |> map { presentationData, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let strings = LumigramStrings(presentationData.strings)
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text(strings.settingsTitle), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries(sections(strings, presentationData.strings)), style: .blocks, animateChanges: false)
        return (controllerState, (listState, openUrl as Any))
    }
    return ItemListController(context: context, state: signal)
}
