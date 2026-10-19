import SwiftUI
import StreetPiCore

struct DNSHub: View {
    var desk: DNSDesk
    var theme: StreetTheme
    var wide: Bool
    var passwordSaved: Bool
    var sessionActive: Bool
    var onPage: (DNSPage) -> Void
    var onSavePassword: () -> Void
    var onSignOut: () -> Void

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
            Text("This phone")
                .font(.headline)
                .foregroundStyle(theme.ink)
            Text(passwordSaved ? "The app password is saved on this phone." : "Not set up on this phone yet.")
                .font(.subheadline)
                .foregroundStyle(theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if !passwordSaved {
                Button("Set up this phone", action: onSavePassword)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(theme.accent)
            }
            if sessionActive {
                Button("Sign out", action: onSignOut)
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
    }
}
