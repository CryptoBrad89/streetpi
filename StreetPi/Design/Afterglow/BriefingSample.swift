import SwiftUI

struct BriefingSample: View {
    @Environment(\.afterglowPalette) private var palette
    @Environment(\.afterglowGate) private var gate

    var body: some View {
        VStack(alignment: .leading, spacing: AfterglowShape.line) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: AfterglowShape.line) {
                    heading
                    Spacer(minLength: AfterglowShape.line)
                    AfterglowButton(title: "Check again", systemImage: "arrow.clockwise", action: checkAgain)
                }
                VStack(alignment: .leading, spacing: AfterglowShape.line) {
                    heading
                    AfterglowButton(title: "Check again", systemImage: "arrow.clockwise", action: checkAgain)
                }
            }
            StatusHeadline(title: "Everything's good.", tone: .calm)
            GlassPanel(showsGlint: true) {
                VStack(alignment: .leading, spacing: AfterglowShape.line) {
                    ComposeText(lines: [
                        "Blocking is on.",
                        "The Pi is answering.",
                        "Backups copied on Sunday.",
                    ])
                    MonoReading(text: "Updated just now")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: AfterglowShape.tight) {
            KickerLabel(text: "StreetPi")
            HStack(spacing: AfterglowShape.tight) {
                Image(systemName: "circle.fill")
                    .font(.caption2)
                    .foregroundStyle(palette.calm)
                    .symbolEffect(.pulse, options: .repeating, isActive: gate.holdsMotion)
                    .accessibilityHidden(true)
                Text("Home network")
                    .font(AfterglowType.metadata)
                    .foregroundStyle(palette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                statusMark
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Home network, all good")
        }
    }

    @ViewBuilder
    private var statusMark: some View {
        if gate.holdsMotion {
            Image(systemName: AfterglowSymbol.status(.calm))
                .font(.footnote)
                .foregroundStyle(palette.calm)
                .symbolEffect(.bounce, value: "calm")
                .accessibilityHidden(true)
        } else {
            Image(systemName: AfterglowSymbol.status(.calm))
                .font(.footnote)
                .foregroundStyle(palette.calm)
                .accessibilityHidden(true)
        }
    }

    private func checkAgain() {}
}
