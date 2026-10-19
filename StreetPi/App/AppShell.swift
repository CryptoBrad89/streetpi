import SwiftUI
import StreetPiCore

struct AppShell: View {
    var section: AppSection
    var direction: DesignDirection
    var appearance: AppearancePreference
    var snapshot: HouseholdSnapshot
    var now: Date
    var onSection: (AppSection) -> Void
    var onAppearance: (AppearancePreference) -> Void
    var onDirection: (DesignDirection) -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var theme: StreetTheme {
        direction.theme(colorScheme)
    }

    private var status: PlainEnglishStatus {
        StatusNarrator.narrate(snapshot, now: now)
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
                .font(.system(.title3, design: .serif))
                .foregroundStyle(theme.ink)
                .padding(.bottom, Rhythm.line)
                .accessibilityAddTraits(.isHeader)
            sidebarButton("Home", section: .home)
            sidebarButton("Settings", section: .settings)
            Spacer(minLength: 0)
            Text(direction.title)
                .font(.caption)
                .foregroundStyle(theme.tertiary)
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
        HStack {
            Text(direction.title)
                .font(.caption)
                .foregroundStyle(theme.tertiary)
                .textCase(.uppercase)
                .tracking(1.2)
            Spacer()
            if section == .settings {
                IconChromeButton(title: "Home", systemImage: "house") {
                    onSection(.home)
                }
            } else {
                IconChromeButton(title: "Settings", systemImage: "gearshape") {
                    onSection(.settings)
                }
            }
        }
        .padding(.horizontal, Rhythm.page)
        .padding(.top, Rhythm.tight)
    }

    @ViewBuilder
    private func detail(wide: Bool) -> some View {
        switch section {
        case .home:
            home(wide: wide)
        case .settings:
            SettingsView(
                theme: theme,
                appearance: appearance,
                direction: direction,
                onAppearance: onAppearance,
                onDirection: onDirection
            )
        }
    }

    @ViewBuilder
    private func home(wide: Bool) -> some View {
        switch direction {
        case .lampblack:
            LampblackHome(theme: theme, snapshot: snapshot, status: status)
        case .harbor:
            HarborHome(theme: theme, snapshot: snapshot, status: status, wide: wide)
        case .porch:
            PorchHome(theme: theme, scheme: colorScheme, snapshot: snapshot, status: status, wide: wide)
        }
    }
}
