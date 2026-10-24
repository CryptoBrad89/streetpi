import StreetPiCore
import SwiftUI

struct RoomTile: View {
    var title: String
    var detail: String
    var word: String
    var symbol: String
    var tone: PlainEnglishStatus.Tone
    var prominent: Bool = false
    var action: () -> Void

    @Environment(\.afterglowPalette) private var palette

    var body: some View {
        Button(action: action) {
            AfterglowPlate(
                cornerRadius: AfterglowShape.tile,
                interactive: true,
                contentPadding: AfterglowShape.tilePadding
            ) {
                VStack(alignment: .leading, spacing: AfterglowShape.tight) {
                    Image(systemName: symbol)
                        .font(.title2)
                        .foregroundStyle(palette.ember)
                        .accessibilityHidden(true)
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(palette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    if showsDetail {
                        MonoReading(text: detail, emphasize: prominent)
                    }
                    StatusChip(title: word, tone: tone)
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(spoken)
    }

    private var showsDetail: Bool {
        !detail.isEmpty && detail.caseInsensitiveCompare(word) != .orderedSame
    }

    private var spoken: String {
        if showsDetail {
            "\(title), \(detail), \(word)"
        } else {
            "\(title), \(word)"
        }
    }
}
