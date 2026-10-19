import SwiftUI
import StreetPiCore

struct DNSStatistics: View {
    var clients: [NamedRow]
    var domains: [NamedRow]
    var blocked: [NamedRow]
    var theme: StreetTheme
    var wide: Bool

    private var isEmpty: Bool { clients.isEmpty && domains.isEmpty && blocked.isEmpty }

    var body: some View {
        DeskScroll(wide: wide) {
            Text("Statistics")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            if isEmpty {
                EmptyNote(title: DNSCopy.topListsTitle, detail: DNSCopy.topListsDetail, theme: theme)
            }
            list("Busiest devices", clients)
            list("Busiest names", domains)
            list("Most often blocked", blocked)
        }
    }

    @ViewBuilder
    private func list(_ title: String, _ rows: [NamedRow]) -> some View {
        heading(title)
        ForEach(rows) { row in
            Text("\(row.name)  \(row.detail)")
                .font(.body)
                .foregroundStyle(theme.ink)
                .fixedSize(horizontal: false, vertical: true)
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
    var rows: [NamedRow]
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
            if rows.isEmpty {
                EmptyNote(title: emptyTitle, detail: emptyDetail, theme: theme)
            } else {
                ForEach(rows) { row in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(row.name)
                            .font(.headline)
                            .foregroundStyle(theme.ink)
                        Text(row.detail)
                            .font(.subheadline)
                            .foregroundStyle(theme.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
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
