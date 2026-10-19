import SwiftUI
import StreetPiCore

struct PorchHome: View {
    var theme: StreetTheme
    var scheme: ColorScheme
    var snapshot: HouseholdSnapshot
    var status: PlainEnglishStatus
    var wide: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.streetPiStill) private var still

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Rhythm.block) {
                card
                metrics
            }
            .padding(.horizontal, Rhythm.page)
            .padding(.vertical, Rhythm.block)
            .frame(maxWidth: wide ? 720 : 560)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
    }

    private var card: some View {
        PorchCard(theme: theme, scheme: scheme) {
            VStack(alignment: .leading, spacing: Rhythm.line) {
                HStack(alignment: .firstTextBaseline, spacing: Rhythm.line) {
                    Image(systemName: "house.fill")
                        .font(.title2)
                        .foregroundStyle(theme.accent)
                        .symbolEffect(
                            .pulse,
                            options: .repeating,
                            isActive: status.tone == .calm && !reduceMotion && !still
                        )
                        .accessibilityHidden(true)
                        .fixedSize()
                        .layoutPriority(1)
                    Text(status.linkLine)
                        .font(.subheadline)
                        .foregroundStyle(theme.secondary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.7)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ToneMark(tone: status.tone, theme: theme)
                        .fixedSize()
                        .layoutPriority(1)
                }
                Text(status.headline)
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .foregroundStyle(theme.ink)
                    .lineLimit(5)
                    .minimumScaleFactor(0.55)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                if let detail = status.detail {
                    Text(detail)
                        .font(.body)
                        .foregroundStyle(theme.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                VStack(alignment: .leading, spacing: Rhythm.tight) {
                    ForEach(HouseholdVoice.porchLines(snapshot), id: \.self) { line in
                        Text(line)
                            .font(.body)
                            .foregroundStyle(theme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, Rhythm.tight)
            }
        }
    }

    private var metrics: some View {
        let stack = dynamicTypeSize.isAccessibilitySize
        return Group {
            if stack {
                VStack(alignment: .leading, spacing: Rhythm.line) {
                    metricCells
                }
            } else {
                HStack(alignment: .top, spacing: Rhythm.line) {
                    metricCells
                }
            }
        }
    }

    @ViewBuilder
    private var metricCells: some View {
        if let cpu = snapshot.machine?.cpuUsedFraction {
            PorchMetric(label: "Load", value: ReadingText.percent(cpu), theme: theme)
        }
        if let temperature = snapshot.machine?.temperatureCelsius {
            PorchMetric(label: "Warmth", value: ReadingText.warmth(temperature), theme: theme)
        }
        if let memory = snapshot.machine?.memoryUsedFraction {
            PorchMetric(label: "Memory", value: ReadingText.percent(memory), theme: theme)
        }
    }
}

private struct PorchCard<Content: View>: View {
    var theme: StreetTheme
    var scheme: ColorScheme
    @Environment(\.streetPiStill) private var still
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(Rhythm.block)
            .background { plate }
    }

    /// Glass does not rasterize in the snapshot harness, and wrapping the type in
    /// `glassEffect` recorded a blank card. The words sit on a solid plate. Glass
    /// is a live iOS 26 layer behind them.
    @ViewBuilder
    private var plate: some View {
        let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)
        if #available(iOS 26, *), scheme == .dark, !still {
            shape
                .fill(theme.surface)
                .glassEffect(.regular.tint(theme.accent.opacity(0.22)), in: .rect(cornerRadius: 28))
        } else if scheme == .dark, !still {
            shape.fill(.ultraThinMaterial)
        } else {
            shape
                .fill(theme.surface)
                .overlay {
                    shape.stroke(theme.hairline, lineWidth: 1)
                }
        }
    }
}

private struct PorchMetric: View {
    var label: String
    var value: String
    var theme: StreetTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(.title2, design: .rounded, weight: .medium))
                .foregroundStyle(theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(theme.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value)")
    }
}
