import StreetPiCore
import SwiftUI

struct StatusHeadline: View {
    var title: String
    var tone: PlainEnglishStatus.Tone

    @Environment(\.afterglowPalette) private var palette
    @Environment(\.afterglowGate) private var gate
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack {
            AuraView(tone: tone)
            Text(title)
                .font(dynamicTypeSize.isAccessibilitySize ? AfterglowType.title : AfterglowType.display)
                .tracking(dynamicTypeSize.isAccessibilitySize ? 0 : -0.5)
                .foregroundStyle(palette.ink)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AfterglowShape.block)
                .background(plate, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(AfterglowShape.line)
        }
        .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 0 : 148)
        .clipShape(RoundedRectangle(cornerRadius: AfterglowShape.panel, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private var plate: Color {
        palette.panelRaised.opacity(gate.usesSolidPlate ? 1 : 0.90)
    }
}
