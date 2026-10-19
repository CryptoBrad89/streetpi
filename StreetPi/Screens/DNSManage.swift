import SwiftUI
import StreetPiCore

struct ManageScreen: View {
    var title: String
    var intro: String
    var rows: [NamedRow]
    var notice: String?
    var addWord: String
    var theme: StreetTheme
    var wide: Bool
    var onAdd: (String) -> Void
    var onRemove: (String) -> Void

    @State private var draft = ""

    var body: some View {
        DeskScroll(wide: wide) {
            Text(title)
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .accessibilityAddTraits(.isHeader)
            Text(intro)
                .font(.body)
                .foregroundStyle(theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let notice {
                Text(notice)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ForEach(rows) { row in
                rowView(row)
            }
            addField
        }
    }

    private func rowView(_ row: NamedRow) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: Rhythm.line) {
                labels(row)
                remove(row.name)
            }
            VStack(alignment: .leading, spacing: Rhythm.tight) {
                labels(row)
                remove(row.name)
            }
        }
        .padding(Rhythm.line)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(theme.hairline, lineWidth: 1)
        }
    }

    private func labels(_ row: NamedRow) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(row.name)
                .font(.headline)
                .foregroundStyle(theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(row.detail)
                .font(.subheadline)
                .foregroundStyle(theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func remove(_ name: String) -> some View {
        Button("Remove") {
            onRemove(name)
        }
        .font(.body.weight(.semibold))
        .foregroundStyle(theme.problem)
        .accessibilityLabel("Remove \(name)")
    }

    private var addField: some View {
        VStack(alignment: .leading, spacing: Rhythm.line) {
            TextField(addWord, text: $draft)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.body)
                .foregroundStyle(theme.ink)
            Button("Add") {
                let name = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { return }
                onAdd(name)
                draft = ""
            }
            .font(.body.weight(.semibold))
            .foregroundStyle(theme.accent)
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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

struct DNSUpkeep: View {
    var desk: DNSDesk
    var theme: StreetTheme
    var wide: Bool
    var now: Date
    var onAction: (HouseholdAction) -> Void

    var body: some View {
        DeskScroll(wide: wide) {
            Text("Upkeep")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text("Lists updated \(AgePhrase.english(from: desk.listsUpdatedAt, to: now)).")
                .font(.body)
                .foregroundStyle(theme.secondary)
            Text(DNSCopy.queryLogDetail)
                .font(.subheadline)
                .foregroundStyle(theme.tertiary)
                .fixedSize(horizontal: false, vertical: true)
            action("Update the block lists") { onAction(.updateBlockLists) }
            action("Restart DNS") { onAction(.restartDNS) }
            action("Clear the query log") { onAction(.flushQueryLog) }
        }
    }

    private func action(_ title: String, perform: @escaping () -> Void) -> some View {
        Button(action: perform) {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.ink)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Rhythm.line)
                .background(theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(theme.hairline, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}
