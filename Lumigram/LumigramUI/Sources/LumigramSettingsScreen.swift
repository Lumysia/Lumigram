import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramPresentationData
import ItemListUI
import AccountContext
import PresentationDataUtils
import LumigramCore
import LumigramBase

private let sourceCodeUrl = "https://github.com/Lumysia/Lumigram"

private struct Section {
    enum Row {
        case toggle(String, LumigramSettings.Key<Bool>)
        case choice(String, LumigramSettings.Key<Int>, value: Int)
        case link(String, url: String)
    }

    let header: String?
    let rows: [Row]
    let footer: String?
}

/// Every Lumigram setting, in screen order. A feature adds its rows here.
private func sections(_ strings: LumigramStrings) -> [Section] {
    return [
        Section(header: strings.chatsHeader, rows: [
            .toggle(strings.secondsInTimestamps, .secondsInTimestamps),
            .toggle(strings.sendWithReturn, .sendWithReturn),
            .toggle(strings.deletionEffect, .deletionEffect),
            .toggle(strings.aiButton, .aiButton),
            .toggle(strings.hideReactions, .hideReactions),
            .toggle(strings.nextChannelSwipe, .nextChannelSwipe),
            .toggle(strings.hideChannelBar, .hideChannelBar),
        ], footer: nil),
        Section(header: strings.chatListHeader, rows: [.toggle(strings.hideStories, .hideStories)], footer: strings.appliesAfterRestart),
        Section(header: strings.profilesHeader, rows: [.toggle(strings.showUserInfo, .showUserInfo)], footer: strings.showUserInfoFooter),
        Section(header: strings.notificationsHeader, rows: [
            .toggle(strings.silentPinnedNotifications, .silentPinnedNotifications),
            .toggle(strings.silentMentionNotifications, .silentMentionNotifications),
        ], footer: strings.notificationsFooter),
        Section(header: strings.privacyHeader, rows: [
            .toggle(strings.linkPreviews, .linkPreviews),
            .toggle(strings.confirmCalls, .confirmCalls),
        ], footer: strings.privacyFooter),
        Section(header: strings.speedBoostHeader, rows: LumigramSpeedBoost.allCases.map { boost -> Section.Row in
            .choice(strings.speedBoost(boost), .speedBoost, value: boost.rawValue)
        }, footer: strings.speedBoostFooter),
        Section(header: strings.aboutHeader, rows: [.link(strings.sourceCode, url: sourceCodeUrl)], footer: strings.aboutFooter),
    ]
}

private final class Arguments {
    let set: (LumigramSettings.Key<Bool>, Bool) -> Void
    let choose: (LumigramSettings.Key<Int>, Int) -> Void
    let openUrl: (String) -> Void

    init(set: @escaping (LumigramSettings.Key<Bool>, Bool) -> Void, choose: @escaping (LumigramSettings.Key<Int>, Int) -> Void, openUrl: @escaping (String) -> Void) {
        self.set = set
        self.choose = choose
        self.openUrl = openUrl
    }
}

private struct Entry: ItemListNodeEntry {
    enum Content: Equatable {
        case header(String)
        case toggle(String, LumigramSettings.Key<Bool>, Bool)
        case choice(String, LumigramSettings.Key<Int>, value: Int, checked: Bool)
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
        let arguments = arguments as! Arguments
        switch self.content {
        case let .header(text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .toggle(title, key, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.set(key, value)
            })
        case let .choice(title, key, value, checked):
            return ItemListCheckboxItem(presentationData: presentationData, systemStyle: .glass, title: title, style: .left, checked: checked, zeroSeparatorInsets: false, sectionId: self.section, action: {
                arguments.choose(key, value)
            })
        case let .link(title, url):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: title, label: "", sectionId: self.section, style: .blocks, action: {
                arguments.openUrl(url)
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
            case let .choice(title, key, value):
                append(.choice(title, key, value: value, checked: LumigramSettings.shared[key] == value))
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
    let changed = ValuePipe<Void>()
    let arguments = Arguments(set: { key, value in
        LumigramSettings.shared[key] = value
        changed.putNext(Void())
    }, choose: { key, value in
        LumigramSettings.shared[key] = value
        changed.putNext(Void())
    }, openUrl: { url in
        context.sharedContext.applicationBindings.openUrl(url)
    })
    let settingsChanged: Signal<Void, NoError> = .single(Void()) |> then(changed.signal())
    let signal = combineLatest(queue: .mainQueue(), context.sharedContext.presentationData, settingsChanged)
    |> map { presentationData, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let strings = LumigramStrings(presentationData.strings)
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text(strings.settingsTitle), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries(sections(strings)), style: .blocks, animateChanges: false)
        return (controllerState, (listState, arguments as Any))
    }
    return ItemListController(context: context, state: signal)
}
