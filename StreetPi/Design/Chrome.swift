import StreetPiCore
import SwiftUI

struct FractionTrack: View {
    var fraction: Double
    var theme: StreetTheme

    var body: some View {
        GeometryReader { proxy in
            let width = max(4, proxy.size.width * min(max(fraction, 0), 1))
            ZStack(alignment: .leading) {
                Capsule().fill(theme.hairline)
                Capsule().fill(theme.accent).frame(width: width)
            }
        }
        .frame(height: 3)
        .accessibilityHidden(true)
    }
}

struct ToneMark: View {
    var tone: PlainEnglishStatus.Tone
    var theme: StreetTheme

    var body: some View {
        Image(systemName: symbol)
            .font(.footnote)
            .foregroundStyle(theme.tone(tone))
            .accessibilityHidden(true)
    }

    private var symbol: String {
        switch tone {
        case .calm: "checkmark.circle.fill"
        case .attention: "exclamationmark.circle.fill"
        case .problem: "xmark.circle.fill"
        }
    }
}

/// Glass is reserved for chrome and the status card. Reading type stays on a solid ground.
struct SkipControl: View {
    var title: String
    var action: () -> Void

    var body: some View {
        if #available(iOS 26, *) {
            Button(title, action: action)
                .buttonStyle(.glass)
        } else {
            Button(title, action: action)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
        }
    }
}

struct IconChromeButton: View {
    var title: String
    var systemImage: String
    var action: () -> Void

    var body: some View {
        if #available(iOS 26, *) {
            Button(title, systemImage: systemImage, action: action)
                .labelStyle(.iconOnly)
                .buttonStyle(.glass)
        } else {
            Button(title, systemImage: systemImage, action: action)
                .labelStyle(.iconOnly)
                .padding(10)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}
