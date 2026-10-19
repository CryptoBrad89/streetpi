import SwiftUI
import StreetPiCore

struct HarborHome: View {
    var theme: StreetTheme
    var snapshot: HouseholdSnapshot
    var status: PlainEnglishStatus
    var wide: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Rhythm.block) {
                header
                instruments
                services
            }
            .padding(.horizontal, Rhythm.page)
            .padding(.bottom, Rhythm.page)
            .frame(maxWidth: 980, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Rhythm.line) {
            HStack(spacing: 8) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(theme.tone(status.tone))
                    .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                    .accessibilityHidden(true)
                Text(status.linkLine)
                    .font(.subheadline.monospaced())
                    .foregroundStyle(theme.secondary)
                Spacer(minLength: 0)
                ToneMark(tone: status.tone, theme: theme)
            }
            Text(status.headline)
                .font(.system(.title, design: .default, weight: .semibold))
                .foregroundStyle(theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            if let detail = status.detail {
                Text(detail)
                    .font(.body)
                    .foregroundStyle(theme.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top, Rhythm.line)
        .padding(.leading, 10)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(theme.accent)
                .frame(width: 3)
                .accessibilityHidden(true)
        }
    }

    private var instruments: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            if let cpu = snapshot.machine?.cpuUsedFraction {
                InstrumentCell(label: "CPU", value: ReadingText.percent(cpu), theme: theme)
            }
            if let temperature = snapshot.machine?.temperatureCelsius {
                InstrumentCell(label: "Temp", value: ReadingText.celsius(temperature), theme: theme)
            }
            if let memory = snapshot.machine?.memoryUsedFraction {
                InstrumentCell(label: "Memory", value: ReadingText.percent(memory), theme: theme)
            }
            if let disk = snapshot.machine?.diskUsedFraction {
                InstrumentCell(label: "Disk", value: ReadingText.percent(disk), theme: theme)
            }
        }
        .background(theme.surface)
        .overlay {
            Rectangle().stroke(theme.hairline, lineWidth: 1)
        }
    }

    private var columns: [GridItem] {
        let count = columnCount
        return Array(repeating: GridItem(.flexible(), spacing: 0), count: count)
    }

    private var columnCount: Int {
        if dynamicTypeSize.isAccessibilitySize {
            return 1
        }
        return wide ? 4 : 2
    }

    private var services: some View {
        VStack(spacing: 0) {
            ForEach(snapshot.services) { service in
                HStack(alignment: .firstTextBaseline, spacing: Rhythm.line) {
                    Text(service.name)
                        .font(.body.weight(.medium))
                        .foregroundStyle(theme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(ReadingText.stateWord(for: service))
                        .font(.body.monospaced())
                        .foregroundStyle(theme.secondary)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.vertical, 14)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(theme.hairline).frame(height: 1)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

private struct InstrumentCell: View {
    var label: String
    var value: String
    var theme: StreetTheme

    var body: some View {
        VStack(alignment: .leading, spacing: Rhythm.tight) {
            Text(label)
                .font(.caption.monospaced())
                .foregroundStyle(theme.tertiary)
                .textCase(.uppercase)
            Text(value)
                .font(.system(.title, design: .monospaced, weight: .medium))
                .foregroundStyle(theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Rhythm.line)
        .overlay {
            Rectangle().stroke(theme.hairline, lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value)")
    }
}
