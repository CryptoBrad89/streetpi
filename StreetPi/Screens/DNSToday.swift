import SwiftUI
import StreetPiCore

struct DNSToday: View {
    var desk: DNSDesk
    var theme: StreetTheme
    var wide: Bool
    var now: Date
    var onAction: (HouseholdAction) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.streetPiStill) private var still
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var minutes = ""

    var body: some View {
        DeskScroll(wide: wide) {
            Text("Today")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            HStack(alignment: .firstTextBaseline, spacing: Rhythm.line) {
                Image(systemName: "shield")
                    .font(.title2)
                    .foregroundStyle(theme.accent)
                    .symbolEffect(
                        .pulse,
                        options: .repeating,
                        isActive: desk.blocking.enabled && !reduceMotion && !still
                    )
                    .accessibilityHidden(true)
                Text(desk.blockingLine)
                    .font(.system(.title3, design: .rounded))
                    .foregroundStyle(theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
            timers
            day
            facts
            Text("Lists updated \(AgePhrase.english(from: desk.listsUpdatedAt, to: now)).")
                .font(.footnote)
                .foregroundStyle(theme.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var day: some View {
        if desk.hasDayLookups {
            DayChart(samples: desk.day, theme: theme)
        } else {
            EmptyNote(title: DNSCopy.emptyChartTitle, detail: DNSCopy.emptyChartDetail, theme: theme)
        }
    }

    private var facts: some View {
        VStack(alignment: .leading, spacing: Rhythm.line) {
            fact("Blocking", desk.blocking.enabled ? "On" : "Paused")
            fact("Devices", "\(desk.knownClients)")
            fact("Block lists", "\(desk.listCount)")
            fact("Queries today", "\(desk.queriesToday)")
            fact("Blocked today", "\(desk.blockedToday)")
        }
        .padding(Rhythm.line)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(theme.hairline, lineWidth: 1)
        }
    }

    private func fact(_ label: String, _ value: String) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondary)
                Spacer(minLength: Rhythm.line)
                Text(value)
                    .font(.system(.title3, design: .rounded))
                    .foregroundStyle(theme.ink)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondary)
                Text(value)
                    .font(.system(.title3, design: .rounded))
                    .foregroundStyle(theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var timers: some View {
        if desk.blocking.enabled {
            VStack(alignment: .leading, spacing: Rhythm.line) {
                Text("Pause for")
                    .font(.headline)
                    .foregroundStyle(theme.ink)
                    .accessibilityAddTraits(.isHeader)
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: Rhythm.line) {
                        pauseChoices
                    }
                } else {
                    ScrollView(.horizontal) {
                        HStack(spacing: Rhythm.line) {
                            pauseChoices
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                customPause
            }
        } else {
            choice("Turn blocking back on", label: "Turn ad blocking back on") {
                onAction(.resumeAdBlocking)
            }
        }
    }

    private var pauseChoices: some View {
        ForEach(PauseLength.presets) { length in
            choice(length.title, label: "Pause for \(length.title)") {
                onAction(.pauseAdBlocking(length))
            }
        }
    }

    private var customLength: PauseLength? {
        guard let value = Int(minutes.trimmingCharacters(in: .whitespaces)) else { return nil }
        return PauseLength(seconds: value * 60)
    }

    private var customPause: some View {
        VStack(alignment: .leading, spacing: Rhythm.line) {
            Text("Custom")
                .font(.headline)
                .foregroundStyle(theme.ink)
            TextField("Minutes", text: $minutes)
                .keyboardType(.numberPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.body)
                .foregroundStyle(theme.ink)
            Button {
                guard let customLength else { return }
                onAction(.pauseAdBlocking(customLength))
            } label: {
                Text("Pause for this long")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(customLength == nil ? theme.tertiary : theme.ink)
                    .padding(.horizontal, Rhythm.line)
                    .frame(minHeight: 44, alignment: .leading)
                    .background(theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(theme.hairline, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .disabled(customLength == nil)
            .accessibilityLabel("Pause for a custom length")
        }
    }

    private func choice(_ title: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.ink)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, Rhythm.line)
                .frame(minHeight: 44, alignment: .leading)
                .background(theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(theme.hairline, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

struct DayChart: View {
    var samples: [DayChartSample]
    var theme: StreetTheme

    var body: some View {
        VStack(alignment: .leading, spacing: Rhythm.line) {
            Text("Last day")
                .font(.headline)
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            bars
            legend
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Lookups over the last day. Blocked and allowed.")
    }

    private var bars: some View {
        let peak = max(1, samples.map { $0.allowed + $0.blocked }.max() ?? 1)
        return HStack(alignment: .bottom, spacing: 3) {
            ForEach(samples) { sample in
                bar(sample, peak: peak)
            }
        }
        .frame(height: 120)
        .accessibilityHidden(true)
    }

    private func bar(_ sample: DayChartSample, peak: Int) -> some View {
        let total = sample.allowed + sample.blocked
        let height = CGFloat(total) / CGFloat(peak) * 120
        let blocked = total == 0 ? 0 : height * CGFloat(sample.blocked) / CGFloat(total)
        return VStack(spacing: 0) {
            Spacer(minLength: 0)
            Rectangle().fill(theme.accent).frame(height: max(blocked, total == 0 ? 0 : 2))
            Rectangle()
                .fill(theme.secondary.opacity(0.45))
                .frame(height: max(height - blocked, 2))
        }
        .frame(maxWidth: .infinity)
    }

    private var legend: some View {
        HStack(spacing: Rhythm.line) {
            legendItem("Blocked", color: theme.accent)
            legendItem("Allowed", color: theme.secondary.opacity(0.45))
        }
        .accessibilityHidden(true)
    }

    private func legendItem(_ title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(title)
                .font(.caption)
                .foregroundStyle(theme.secondary)
        }
    }
}
