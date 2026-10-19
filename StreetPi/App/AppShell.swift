import SwiftUI
import StreetPiCore

struct AppShell: View {
    var section: AppSection
    var appearance: AppearancePreference
    var screen: HouseScreen
    var now: Date
    var onSection: (AppSection) -> Void
    var onAppearance: (AppearancePreference) -> Void

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
            sidebarButton("Settings", section: .settings)
            Spacer(minLength: 0)
        }
        .padding(Rhythm.page)
        .frame(maxHeight: .infinity, alignment: .topLeading)
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
        case .group(let group):
            group.title
        }
    }

    @ViewBuilder
    private var chromeButton: some View {
        switch section {
        case .group:
            IconChromeButton(title: "Home", systemImage: "chevron.backward") {
                onSection(.home)
            }
        case .settings:
            IconChromeButton(title: "Home", systemImage: "house") {
                onSection(.home)
            }
        case .home:
            IconChromeButton(title: "Settings", systemImage: "gearshape") {
                onSection(.settings)
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
        case .group(let group):
            if let brief = groups.first(where: { $0.id == group }) {
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

    private var lines: [String] {
        guard let snapshot = screen.snapshot, !snapshot.isEmptyHouse else { return [] }
        return HouseholdVoice.porchLines(snapshot)
    }
}
