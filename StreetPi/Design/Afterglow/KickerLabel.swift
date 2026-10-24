import SwiftUI

struct KickerLabel: View {
    var text: String

    @Environment(\.afterglowPalette) private var palette
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Text(text)
            .font(AfterglowType.kicker)
            .tracking(dynamicTypeSize.isAccessibilitySize ? 0 : 1.4)
            .foregroundStyle(palette.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }
}
