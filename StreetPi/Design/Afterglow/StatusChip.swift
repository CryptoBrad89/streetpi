import StreetPiCore
import SwiftUI

struct StatusChip: View {
    var title: String
    var tone: PlainEnglishStatus.Tone
    var symbol: String?

    @Environment(\.afterglowPalette) private var palette

    init(title: String, tone: PlainEnglishStatus.Tone, symbol: String? = nil) {
        self.title = title
        self.tone = tone
        self.symbol = symbol
    }

    var body: some View {
        Label {
            Text(title)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: symbol ?? AfterglowSymbol.status(tone))
                .accessibilityHidden(true)
        }
        .font(AfterglowType.chip)
        .foregroundStyle(palette.tone(tone))
        .labelStyle(.titleAndIcon)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(minHeight: 32)
        .background(palette.tone(tone).opacity(0.16), in: Capsule())
        .overlay {
            Capsule().strokeBorder(palette.hairline, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}
