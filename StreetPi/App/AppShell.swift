import SwiftUI
import StreetPiCore

struct AppShell: View {
    var section: AppSection
    var appearance: AppearancePreference
    var screen: HouseScreen
    var now: Date
    var onSection: (AppSection) -> Void
    var onAppearance: (AppearancePreference) -> Void
    var desk: DNSDesk = .houseFixture
    var dnsPage: DNSPage?
    var machine: MachineDesk = .houseFixture
    var machinePage: MachinePage?
    var pendingAction: HouseholdAction?
    var passwordSaved: Bool = true
    var keySaved: Bool = true
    var onDNSPage: (DNSPage?) -> Void = { _ in }
    var onMachinePage: (MachinePage?) -> Void = { _ in }
    var onPending: (HouseholdAction?) -> Void = { _ in }
    var onConfirm: (HouseholdAction) -> Void = { _ in }
    var onSavePassword: () -> Void = {}

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var theme: StreetTheme {
        .house(colorScheme)
    }

    private var status: PlainEnglishStatus {
        screen.status(now: now)
    }

    private var groups: [GroupBrief] {
        guard let snapshot = screen.snapshot else { return [] }
        return HouseGuide.groups(in: snapshot)
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            GeometryReader { proxy in
                shell(wide: proxy.size.width >= 760)
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
            }
            if let pendingAction {
                ActionConfirm(
                    action: pendingAction,
                    theme: theme,
                    onCancel: { onPending(nil) },
                    onConfirm: { onConfirm(pendingAction) }
                )
            }
        }
        .tint(theme.accent)
    }

    private func shell(wide: Bool) -> some View {
        Group {
            if wide {
                HStack(spacing: 0) {
                    sidebar
                        .frame(width: 248)
                        .background(theme.surface)
                    Rectangle()
                        .fill(theme.hairline)
                        .frame(width: 1)
                        .accessibilityHidden(true)
                    detail(wide: true)
                }
            } else {
                VStack(spacing: 0) {
                    phoneChrome
                    detail(wide: false)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(theme.background)
    }

    private var sidebar: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Rhythm.line) {
                Text("StreetPi")
                    .font(.system(.title3, design: .rounded))
                    .foregroundStyle(theme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.bottom, Rhythm.line)
                    .accessibilityAddTraits(.isHeader)
                sidebarButton("Home", section: .home)
                ForEach(groups) { group in
                    sidebarButton(group.title, section: .group(group.id))
                }
                sidebarButton("Alerts", section: .alerts)
                sidebarButton("Settings", section: .settings)
            }
            .padding(Rhythm.page)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
    }

    private func sidebarButton(_ title: String, section target: AppSection) -> some View {
        let selected = section == target
        return Button(title) {
            onSection(target)
        }
        .font(.body.weight(selected ? .semibold : .regular))
        .foregroundStyle(selected ? theme.ink : theme.secondary)
        .multilineTextAlignment(.leading)
        .lineLimit(2)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            selected ? theme.background : Color.clear,
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var phoneChrome: some View {
        let title = Text(chromeTitle)
            .font(.caption)
            .foregroundStyle(theme.tertiary)
            .textCase(.uppercase)
            .tracking(dynamicTypeSize.isAccessibilitySize ? 0 : 1.2)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        return Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Rhythm.tight) {
                    HStack {
                        Spacer(minLength: 0)
                        chromeButton
                    }
                    title
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                HStack(spacing: Rhythm.line) {
                    title
                    Spacer(minLength: Rhythm.line)
                    chromeButton
                }
            }
        }
        .padding(.horizontal, Rhythm.page)
        .padding(.top, Rhythm.tight)
    }

    private var chromeTitle: String {
        switch section {
        case .home, .settings:
            "StreetPi"
        case .alerts:
            "Alerts"
        case .group(let group):
            nestedTitle(group)
        }
    }

    private func nestedTitle(_ group: HouseGroup) -> String {
        if group == .adBlockerAndDNS, let dnsPage {
            return dnsPage.title
        }
        if group == .piHealth, let machinePage {
            return machinePage.title
        }
        return group.title
    }

    @ViewBuilder
    private var chromeButton: some View {
        switch section {
        case .group(let group):
            groupBack(group)
        case .settings, .alerts:
            IconChromeButton(title: "Home", systemImage: "house") {
                onSection(.home)
            }
        case .home:
            HStack(spacing: 8) {
                IconChromeButton(title: "Alerts", systemImage: "bell") {
                    onSection(.alerts)
                }
                IconChromeButton(title: "Settings", systemImage: "gearshape") {
                    onSection(.settings)
                }
            }
        }
    }

    @ViewBuilder
    private func groupBack(_ group: HouseGroup) -> some View {
        if group == .adBlockerAndDNS, dnsPage != nil {
            IconChromeButton(title: "Ad blocker & DNS", systemImage: "chevron.backward") {
                onDNSPage(nil)
            }
        } else if group == .piHealth, machinePage != nil {
            IconChromeButton(title: "Pi health", systemImage: "chevron.backward") {
                onMachinePage(nil)
            }
        } else {
            IconChromeButton(title: "Home", systemImage: "chevron.backward") {
                onSection(.home)
            }
        }
    }

    @ViewBuilder
    private func detail(wide: Bool) -> some View {
        switch section {
        case .home:
            HomeView(
                theme: theme,
                scheme: colorScheme,
                snapshot: screen.snapshot,
                status: status,
                lines: lines,
                groups: groups,
                wide: wide,
                onGroup: { onSection(.group($0)) }
            )
        case .alerts:
            AlertsScreen(alerts: machine.alerts, theme: theme, wide: wide)
        case .group(let group):
            if group == .adBlockerAndDNS {
                dnsDetail(wide: wide)
            } else if group == .piHealth {
                machineDetail(wide: wide)
            } else if let brief = groups.first(where: { $0.id == group }) {
                GroupDashboard(
                    theme: theme,
                    brief: brief,
                    machine: screen.snapshot?.machine,
                    wide: wide
                )
            } else {
                HomeView(
                    theme: theme,
                    scheme: colorScheme,
                    snapshot: nil,
                    status: PlainEnglishStatus(
                        headline: "Nothing in \(group.title) yet.",
                        detail: nil,
                        tone: .calm,
                        linkLine: status.linkLine
                    ),
                    lines: [],
                    groups: [],
                    wide: wide,
                    onGroup: { _ in }
                )
            }
        case .settings:
            SettingsView(theme: theme, appearance: appearance, onAppearance: onAppearance)
        }
    }

    @ViewBuilder
    private func dnsDetail(wide: Bool) -> some View {
        if let dnsPage {
            VStack(alignment: .leading, spacing: 0) {
                if wide {
                    WideBack(title: "Ad blocker & DNS", theme: theme) {
                        onDNSPage(nil)
                    }
                    .padding(.horizontal, Rhythm.page)
                    .padding(.top, Rhythm.line)
                }
                DNSPageBody(
                    page: dnsPage,
                    desk: desk,
                    theme: theme,
                    wide: wide,
                    now: now,
                    onAction: { onPending($0) }
                )
            }
        } else {
            DNSHub(
                desk: desk,
                theme: theme,
                wide: wide,
                passwordSaved: passwordSaved,
                onPage: { onDNSPage($0) },
                onSavePassword: onSavePassword
            )
        }
    }

    @ViewBuilder
    private func machineDetail(wide: Bool) -> some View {
        if let machinePage {
            VStack(alignment: .leading, spacing: 0) {
                if wide {
                    WideBack(title: "Pi health", theme: theme) {
                        onMachinePage(nil)
                    }
                    .padding(.horizontal, Rhythm.page)
                    .padding(.top, Rhythm.line)
                }
                MachinePageBody(
                    page: machinePage,
                    desk: machine,
                    machine: screen.snapshot?.machine,
                    theme: theme,
                    wide: wide,
                    now: now,
                    keySaved: keySaved,
                    onAction: { onPending($0) }
                )
            }
        } else if let reading = screen.snapshot?.machine {
            MachineHome(
                desk: machine,
                machine: reading,
                theme: theme,
                wide: wide,
                onPage: { onMachinePage($0) }
            )
        }
    }

    private var lines: [String] {
        guard let snapshot = screen.snapshot, !snapshot.isEmptyHouse else { return [] }
        return HouseholdVoice.porchLines(snapshot)
    }
}
