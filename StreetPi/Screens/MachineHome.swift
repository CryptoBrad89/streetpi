import SwiftUI
import StreetPiCore

struct MachineHome: View {
    var desk: MachineDesk
    var machine: MachineReading?
    var theme: StreetTheme
    var wide: Bool
    var onPage: (MachinePage) -> Void

    var body: some View {
        DeskScroll(wide: wide) {
            VStack(alignment: .leading, spacing: Rhythm.tight) {
                Text("The Pi")
                    .font(.system(.largeTitle, design: .rounded))
                    .foregroundStyle(theme.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("\(desk.modelName) at \(desk.host)")
                    .font(.title3)
                    .foregroundStyle(theme.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let cpu = machine?.cpuUsedFraction {
                meter("Processor", ReadingText.percent(cpu), cpu)
            }
            if let temperature = machine?.temperatureCelsius {
                meter("Temperature", "\(ReadingText.celsius(temperature))  \(ReadingText.warmth(temperature))", nil)
            }
            if let memory = machine?.memoryUsedFraction {
                meter("Memory", ReadingText.percent(memory), memory)
            }
            if let disk = machine?.diskUsedFraction {
                meter("Disk", ReadingText.percent(disk), disk)
            }
            ForEach(MachinePage.allCases.filter { $0 != .dashboard }) { page in
                DeskLink(title: page.title, blurb: page.blurb, symbol: page.symbolName, theme: theme) {
                    onPage(page)
                }
            }
        }
    }

    private func meter(_ label: String, _ value: String, _ fraction: Double?) -> some View {
        VStack(alignment: .leading, spacing: Rhythm.tight) {
            HStack {
                Text(label).font(.subheadline).foregroundStyle(theme.secondary)
                Spacer(minLength: Rhythm.line)
                Text(value).font(.system(.title3, design: .rounded)).foregroundStyle(theme.ink)
            }
            if let fraction {
                FractionTrack(fraction: fraction, theme: theme)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct MetricChartScreen: View {
    var points: [MetricPoint]
    var theme: StreetTheme
    var wide: Bool

    var body: some View {
        DeskScroll(wide: wide) {
            Text("Processor")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text("The last day, from the sample.")
                .font(.body)
                .foregroundStyle(theme.secondary)
            chart
        }
    }

    private var chart: some View {
        let peak = max(0.01, points.map(\.value).max() ?? 1)
        return HStack(alignment: .bottom, spacing: 3) {
            ForEach(points) { point in
                Rectangle()
                    .fill(theme.accent)
                    .frame(height: CGFloat(point.value / peak) * 140)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 140, alignment: .bottom)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Processor over the last day")
    }
}
