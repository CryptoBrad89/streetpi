import SwiftUI
import StreetPiCore

struct MachineListScreen: View {
    var title: String
    var intro: String
    var rows: [NamedRow]
    var actionTitle: String?
    var theme: StreetTheme
    var wide: Bool
    var onRow: (String) -> Void

    var body: some View {
        DeskScroll(wide: wide) {
            Text(title)
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text(intro)
                .font(.body)
                .foregroundStyle(theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(rows) { row in
                VStack(alignment: .leading, spacing: Rhythm.tight) {
                    Text(row.name).font(.headline).foregroundStyle(theme.ink)
                    Text(row.detail).font(.subheadline).foregroundStyle(theme.secondary)
                    if let actionTitle {
                        Button(actionTitle) { onRow(row.name) }
                            .font(.body.weight(.semibold))
                            .foregroundStyle(theme.accent)
                            .accessibilityLabel("\(actionTitle) \(row.name)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Rhythm.line)
                .background(theme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }
}

struct ActivityScreen: View {
    var rows: [ActivityRow]
    var theme: StreetTheme
    var wide: Bool
    var now: Date

    var body: some View {
        DeskScroll(wide: wide) {
            Text("Activity")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            ForEach(rows) { row in
                VStack(alignment: .leading, spacing: 4) {
                    Text(row.sentence).font(.headline).foregroundStyle(theme.ink)
                    Text(AgePhrase.english(from: row.when, to: now))
                        .font(.subheadline)
                        .foregroundStyle(theme.secondary)
                }
            }
            Text("Spreadsheet")
                .font(.headline)
                .foregroundStyle(theme.ink)
            Text(ActivityExport.csv(rows))
                .font(.caption.monospaced())
                .foregroundStyle(theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct AlertsScreen: View {
    var alerts: [HouseAlert]
    var theme: StreetTheme
    var wide: Bool

    var body: some View {
        DeskScroll(wide: wide) {
            Text("Alerts")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text("These stay in the app. StreetPi does not send push notifications.")
                .font(.body)
                .foregroundStyle(theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(alerts) { alert in
                HStack(alignment: .top, spacing: Rhythm.line) {
                    ToneMark(tone: alert.tone, theme: theme)
                    Text(alert.sentence)
                        .font(.body)
                        .foregroundStyle(theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct PowerScreen: View {
    var theme: StreetTheme
    var wide: Bool
    var onAction: (HouseholdAction) -> Void

    var body: some View {
        DeskScroll(wide: wide) {
            Text("Power")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text("These stop the house until the Pi is back.")
                .font(.body)
                .foregroundStyle(theme.secondary)
            choice("Restart the Pi") { onAction(.reboot) }
            choice("Turn the Pi off") { onAction(.shutDown) }
        }
    }

    private func choice(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Rhythm.line)
                .background(theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
