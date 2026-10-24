import SwiftUI

struct AfterglowButton: View {
    var title: String
    var systemImage: String
    var action: () -> Void

    @Environment(\.afterglowPalette) private var palette
    @Environment(\.afterglowGate) private var gate

    var body: some View {
        if gate.usesSolidPlate {
            labeledButton
                .background(palette.panelRaised, in: Capsule())
                .overlay {
                    Capsule().strokeBorder(palette.hairlineInteractive, lineWidth: 1)
                }
        } else if #available(iOS 26, *) {
            Button(title, systemImage: systemImage, action: action)
                .labelStyle(.titleAndIcon)
                .buttonStyle(.glass)
                .frame(minHeight: 44)
        } else {
            labeledButton
                .background(.ultraThinMaterial, in: Capsule())
                .overlay {
                    Capsule().strokeBorder(palette.hairlineInteractive, lineWidth: 1)
                }
        }
    }

    private var labeledButton: some View {
        Button(action: action) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: systemImage)
                    .foregroundStyle(palette.ember)
                    .accessibilityHidden(true)
            }
            .font(AfterglowType.label)
            .foregroundStyle(palette.ink)
            .labelStyle(.titleAndIcon)
            .frame(minHeight: 44)
            .padding(.horizontal, 14)
        }
        .buttonStyle(.plain)
    }
}
