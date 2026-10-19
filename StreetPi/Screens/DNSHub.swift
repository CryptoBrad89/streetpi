import SwiftUI
import StreetPiCore

struct DNSHub: View {
    var desk: DNSDesk
    var theme: StreetTheme
    var wide: Bool
    var passwordSaved: Bool
    var onPage: (DNSPage) -> Void
    var onSavePassword: () -> Void

    var body: some View {
        DeskScroll(wide: wide) {
            VStack(alignment: .leading, spacing: Rhythm.tight) {
                Text("Ad blocker & DNS")
                    .font(.system(.largeTitle, design: .rounded))
                    .foregroundStyle(theme.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text(desk.blockingLine)
                    .font(.title3)
                    .foregroundStyle(theme.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(DNSCopy.queryLogDetail)
                    .font(.subheadline)
                    .foregroundStyle(theme.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            passwordRow
            ForEach(DNSShelf.allCases) { shelf in
                VStack(alignment: .leading, spacing: Rhythm.line) {
                    Text(shelf.title)
                        .font(.headline)
                        .foregroundStyle(theme.ink)
                        .accessibilityAddTraits(.isHeader)
                    ForEach(shelf.pages) { page in
                        DeskLink(
                            title: page.title,
                            blurb: page.blurb,
                            symbol: page.symbolName,
                            theme: theme
                        ) {
                            onPage(page)
                        }
                    }
                }
            }
        }
    }

    private var passwordRow: some View {
        VStack(alignment: .leading, spacing: Rhythm.line) {
            Text("App password")
                .font(.headline)
                .foregroundStyle(theme.ink)
            Text(passwordSaved ? "Saved on this phone." : "Not on this phone yet.")
                .font(.subheadline)
                .foregroundStyle(theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if !passwordSaved {
                Button("Save it on this phone", action: onSavePassword)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(theme.accent)
            }
        }
        .padding(Rhythm.line)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(theme.hairline, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}
