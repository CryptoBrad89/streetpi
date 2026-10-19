import SwiftUI
import StreetPiCore

struct DNSPageBody: View {
    var page: DNSPage
    var desk: DNSDesk
    var theme: StreetTheme
    var wide: Bool
    var now: Date
    var onAction: (HouseholdAction) -> Void

    var body: some View {
        switch page {
        case .today:
            DNSToday(desk: desk, theme: theme, wide: wide, now: now, onAction: onAction)
        case .statistics:
            DNSStatistics(theme: theme, wide: wide)
        case .queryLog:
            DNSLogScreen(
                title: page.title,
                emptyTitle: DNSCopy.queryLogTitle,
                emptyDetail: DNSCopy.queryLogDetail,
                theme: theme,
                wide: wide
            )
        case .liveLog:
            DNSLogScreen(
                title: page.title,
                emptyTitle: DNSCopy.liveLogTitle,
                emptyDetail: DNSCopy.liveLogDetail,
                theme: theme,
                wide: wide
            )
        case .services:
            DNSServices(services: desk.services, theme: theme, wide: wide, onAction: onAction)
        case .clients:
            manage(
                intro: "Devices the house knows.",
                rows: desk.clients,
                add: "A device name",
                kind: .client
            )
        case .groups:
            manage(intro: "Devices that share a rule.", rows: desk.groups, add: "A group name", kind: .group)
        case .domains:
            manage(intro: "Names to block or allow.", rows: desk.domains, add: "A domain name", kind: .domain)
        case .lists:
            manage(
                intro: "Lists the filter downloads.",
                rows: desk.lists.map { NamedRow(id: $0.id, name: $0.name, detail: $0.host) },
                add: "A list name",
                kind: .blockList
            )
        case .localNames:
            manage(
                intro: "Names that stay inside the house.",
                rows: desk.localNames,
                notice: DNSCopy.localNameNotice,
                add: "A house name",
                kind: .localName
            )
        case .upkeep:
            DNSUpkeep(desk: desk, theme: theme, wide: wide, now: now, onAction: onAction)
        }
    }

    private func manage(
        intro: String,
        rows: [NamedRow],
        notice: String? = nil,
        add: String,
        kind: DNSEntryKind
    ) -> some View {
        ManageScreen(
            title: page.title,
            intro: intro,
            rows: rows,
            notice: notice,
            addWord: add,
            theme: theme,
            wide: wide,
            onAdd: { onAction(addAction($0, kind: kind)) },
            onRemove: { onAction(.removeDNSEntry(kind, named: $0)) }
        )
    }

    private func addAction(_ name: String, kind: DNSEntryKind) -> HouseholdAction {
        switch kind {
        case .client: .addClient(named: name)
        case .group: .addGroup(named: name)
        case .domain: .addDomain(named: name, blocked: true)
        case .blockList: .addBlockList(named: name)
        case .localName: .addLocalName(named: name)
        }
    }
}
