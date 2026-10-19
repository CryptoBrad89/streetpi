import SwiftUI
import StreetPiCore

struct DNSStatistics: View {
    var theme: StreetTheme
    var wide: Bool

    var body: some View {
        DeskScroll(wide: wide) {
            Text("Statistics")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            EmptyNote(title: DNSCopy.topListsTitle, detail: DNSCopy.topListsDetail, theme: theme)
            heading("Busiest devices")
            heading("Busiest names")
            heading("Most often blocked")
        }
    }

    private func heading(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(theme.secondary)
            .accessibilityAddTraits(.isHeader)
    }
}

struct DNSLogScreen: View {
    var title: String
    var emptyTitle: String
    var emptyDetail: String
    var theme: StreetTheme
    var wide: Bool

    var body: some View {
        DeskScroll(wide: wide) {
            Text(title)
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .accessibilityAddTraits(.isHeader)
            EmptyNote(title: emptyTitle, detail: emptyDetail, theme: theme)
        }
    }
}

struct DNSServices: View {
    var services: [DNSServiceChoice]
    var theme: StreetTheme
    var wide: Bool
    var onAction: (HouseholdAction) -> Void

    var body: some View {
        DeskScroll(wide: wide) {
            Text("Services")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text("Turn a whole kind of site off for the house.")
                .font(.body)
                .foregroundStyle(theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(services) { service in
                VStack(alignment: .leading, spacing: Rhythm.tight) {
                    Text(service.name)
                        .font(.headline)
                        .foregroundStyle(theme.ink)
                    Text(service.detail)
                        .font(.subheadline)
                        .foregroundStyle(theme.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(service.blocked ? "Blocked" : "Allowed")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.ink)
                    Button(service.blocked ? "Allow it" : "Block it") {
                        onAction(.setServiceBlocked(named: service.name, blocked: !service.blocked))
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(theme.accent)
                }
                .padding(Rhythm.line)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(theme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(theme.hairline, lineWidth: 1)
                }
            }
        }
    }
}
