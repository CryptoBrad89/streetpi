import SwiftUI

/// Wraps sibling glass views. Solid plates skip the container so snapshots stay opaque.
struct GlassGroup<Content: View>: View {
    var spacing: CGFloat
    @ViewBuilder var content: Content

    @Environment(\.afterglowGate) private var gate

    var body: some View {
        if gate.usesSolidPlate {
            content
        } else if #available(iOS 26, *) {
            GlassEffectContainer(spacing: spacing) {
                content
            }
        } else {
            content
        }
    }
}
