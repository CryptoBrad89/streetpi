import SwiftUI
import StreetPiCore

struct LampblackHome: View {
    var theme: StreetTheme
    var snapshot: HouseholdSnapshot
    var status: PlainEnglishStatus

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Rhythm.block) {
                header
                readings
                services
            }
            .padding(.horizontal, Rhythm.page)
            .padding(.bottom, Rhythm.page)
            .frame(maxWidth: 680, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Rhythm.line) {
            HStack(spacing: 8) {
                ToneMark(tone: status.tone, theme: theme)
                Text(status.linkLine)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondary)
            }
            Text(status.headline)
                .font(.system(.largeTitle, design: .serif))
                .foregroundStyle(theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Capsule()
                .fill(theme.tone(status.tone))
                .frame(width: 56, height: 3)
                .accessibilityHidden(true)
            if let detail = status.detail {
                Text(detail)
                    .font(.body)
                    .foregroundStyle(theme.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let uptime = snapshot.machine?.uptimeSeconds {
                Text(ReadingText.uptime(uptime))
                    .font(.subheadline)
                    .foregroundStyle(theme.tertiary)
            }
        }
        .padding(.top, Rhythm.line)
    }

    private var readings: some View {
        VStack(alignment: .leading, spacing: Rhythm.block) {
            if let cpu = snapshot.machine?.cpuUsedFraction {
                MetricLine(label: "Processor", value: ReadingText.percent(cpu), fraction: cpu, theme: theme)
            }
            if let temperature = snapshot.machine?.temperatureCelsius {
                MetricLine(
                    label: "Temperature",
                    value: "\(ReadingText.celsius(temperature))  \(ReadingText.warmth(temperature))",
                    fraction: nil,
                    theme: theme
                )
            }
            if let memory = snapshot.machine?.memoryUsedFraction {
                MetricLine(label: "Memory", value: ReadingText.percent(memory), fraction: memory, theme: theme)
            }
            if let disk = snapshot.machine?.diskUsedFraction {
                MetricLine(label: "Disk", value: ReadingText.percent(disk), fraction: disk, theme: theme)
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
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(service.name)
                            .font(.title3)
                            .foregroundStyle(theme.ink)
                        Spacer(minLength: Rhythm.line)
                        Text(ReadingText.stateWord(for: service))
                            .font(.body)
                            .foregroundStyle(theme.secondary)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(service.name)
                            .font(.title3)
                            .foregroundStyle(theme.ink)
                        Text(ReadingText.stateWord(for: service))
                            .font(.body)
                            .foregroundStyle(theme.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
                Rectangle()
                    .fill(theme.hairline)
                    .frame(height: 1)
            }
        }
        .padding(.top, Rhythm.line)
    }
}

private struct MetricLine: View {
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
                        .font(.system(.title2, design: .serif))
                        .foregroundStyle(theme.ink)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.subheadline)
                        .foregroundStyle(theme.secondary)
                    Text(value)
                        .font(.system(.title2, design: .serif))
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
