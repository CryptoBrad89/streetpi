import StreetPiCore
import SwiftUI

struct RingGauge: View {
    var label: String
    var value: String
    var spoken: String
    var fraction: Double
    var symbol: String
    var word: String?
    var tone: PlainEnglishStatus.Tone

    @Environment(\.afterglowPalette) private var palette
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                row
            } else {
                dial
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken)
    }

    private var dial: some View {
        VStack(spacing: AfterglowShape.tight) {
            ZStack {
                Circle()
                    .stroke(palette.hairline, lineWidth: 8)
                Circle()
                    .trim(from: 0, to: clamped)
                    .stroke(palette.ember, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                MonoReading(text: value, emphasize: true)
            }
            .frame(width: 108, height: 108)
            .accessibilityHidden(true)
            Label {
                Text(label)
                    .fixedSize(horizontal: false, vertical: true)
            } icon: {
                Image(systemName: symbol)
                    .accessibilityHidden(true)
            }
            .font(AfterglowType.label)
            .foregroundStyle(palette.secondary)
            .labelStyle(.titleAndIcon)
            .multilineTextAlignment(.center)
            if let word {
                StatusChip(title: word, tone: tone)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var row: some View {
        HStack(alignment: .center, spacing: AfterglowShape.line) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(palette.ember)
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: AfterglowShape.tight) {
                Text(label)
                    .font(.headline)
                    .foregroundStyle(palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if let word {
                    StatusChip(title: word, tone: tone)
                }
            }
            Spacer(minLength: AfterglowShape.line)
            MonoReading(text: value, emphasize: true)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
    }

    private var clamped: Double {
        min(max(fraction, 0), 1)
    }
}
