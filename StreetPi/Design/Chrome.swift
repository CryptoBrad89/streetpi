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

struct IconChromeButton: View {
    var title: String
    var systemImage: String
    var action: () -> Void

    var body: some View {
        if #available(iOS 26, *) {
            Button(title, systemImage: systemImage, action: action)
                .labelStyle(.iconOnly)
                .buttonStyle(.glass)
                .frame(minWidth: 44, minHeight: 44)
        } else {
            Button(title, systemImage: systemImage, action: action)
                .labelStyle(.iconOnly)
                .frame(minWidth: 44, minHeight: 44)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}

struct ChromeButtonPair<First: View, Second: View>: View {
    var first: First
    var second: Second

    var body: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: 8) {
                HStack(spacing: 8) {
                    first
                    second
                }
            }
        } else {
            HStack(spacing: 8) {
                first
                second
            }
        }
    }
}
