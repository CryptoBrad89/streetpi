import SwiftUI
import StreetPiCore

struct HomeView: View {
    var theme: StreetTheme
    var scheme: ColorScheme
    var snapshot: HouseholdSnapshot
    var status: PlainEnglishStatus
    var wide: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Rhythm.block) {
                statusCard
                readings
                services
            }
            .padding(.horizontal, Rhythm.page)
            .padding(.vertical, Rhythm.block)
            .frame(maxWidth: wide ? 720 : 560)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
    }

    private var statusCard: some View {
        StatusCard(theme: theme, scheme: scheme) {
            VStack(alignment: .leading, spacing: Rhythm.line) {
                StatusLinkRow(text: status.linkLine, tone: status.tone, theme: theme, pulsing: status.tone == .calm)
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

    private var readings: some View {
        VStack(alignment: .leading, spacing: Rhythm.block) {
            if let cpu = snapshot.machine?.cpuUsedFraction {
                MeterRow(label: "Processor", value: ReadingText.percent(cpu), fraction: cpu, theme: theme)
            }
            if let temperature = snapshot.machine?.temperatureCelsius {
                MeterRow(
                    label: "Temperature",
                    value: "\(ReadingText.celsius(temperature))  \(ReadingText.warmth(temperature))",
                    fraction: nil,
                    theme: theme
                )
            }
            if let memory = snapshot.machine?.memoryUsedFraction {
                MeterRow(label: "Memory", value: ReadingText.percent(memory), fraction: memory, theme: theme)
            }
            if let disk = snapshot.machine?.diskUsedFraction {
                MeterRow(label: "Disk", value: ReadingText.percent(disk), fraction: disk, theme: theme)
            }
        }
    }

    private var services: some View {
        VStack(alignment: .leading, spacing: Rhythm.line) {
            Text("Services")
                .font(.footnote)
                .foregroundStyle(theme.tertiary)
                .textCase(.uppercase)
                .tracking(1.1)
            ForEach(snapshot.services) { service in
                ServiceRow(name: service.name, state: ReadingText.stateWord(for: service), theme: theme)
                Rectangle()
                    .fill(theme.hairline)
                    .frame(height: 1)
            }
        }
        .padding(.top, Rhythm.line)
    }
}

private struct StatusLinkRow: View {
    var text: String
    var tone: PlainEnglishStatus.Tone
    var theme: StreetTheme
    var pulsing: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.streetPiStill) private var still

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Rhythm.line) {
            Image(systemName: "house.fill")
                .font(.title2)
                .foregroundStyle(theme.accent)
                .symbolEffect(.pulse, options: .repeating, isActive: pulsing && !reduceMotion && !still)
                .accessibilityHidden(true)
                .fixedSize()
                .layoutPriority(1)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(theme.secondary)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            ToneMark(tone: tone, theme: theme)
                .fixedSize()
                .layoutPriority(1)
        }
    }
}

private struct StatusCard<Content: View>: View {
    var theme: StreetTheme
    var scheme: ColorScheme
    @Environment(\.streetPiStill) private var still
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(Rhythm.block)
            .background { plate }
    }

    /// Glass does not rasterize in the snapshot harness. The words sit on a solid plate.
    /// On a live iOS 26 phone, glass is a layer behind that plate.
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

private struct MeterRow: View {
    var label: String
    var value: String
    var fraction: Double?
    var theme: StreetTheme

    var body: some View {
        VStack(alignment: .leading, spacing: Rhythm.tight) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    Text(label)
                        .font(.subheadline)
                        .foregroundStyle(theme.secondary)
                    Spacer(minLength: Rhythm.line)
                    Text(value)
                        .font(.system(.title2, design: .rounded))
                        .foregroundStyle(theme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.subheadline)
                        .foregroundStyle(theme.secondary)
                    Text(value)
                        .font(.system(.title2, design: .rounded))
                        .foregroundStyle(theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            if let fraction {
                FractionTrack(fraction: fraction, theme: theme)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value)")
    }
}

private struct ServiceRow: View {
    var name: String
    var state: String
    var theme: StreetTheme

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline) {
                Text(name)
                    .font(.title3)
                    .foregroundStyle(theme.ink)
                Spacer(minLength: Rhythm.line)
                Text(state)
                    .font(.body)
                    .foregroundStyle(theme.secondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.title3)
                    .foregroundStyle(theme.ink)
                Text(state)
                    .font(.body)
                    .foregroundStyle(theme.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
