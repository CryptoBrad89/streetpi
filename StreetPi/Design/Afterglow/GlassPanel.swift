import SwiftUI

struct GlassPanel<Content: View>: View {
    var showsGlint: Bool = false
    @ViewBuilder var content: Content

    var body: some View {
        AfterglowPlate(
            cornerRadius: AfterglowShape.panel,
            interactive: false,
            contentPadding: AfterglowShape.panelPadding
        ) {
            content
        }
        .overlay {
            GlintBorder(active: showsGlint, cornerRadius: AfterglowShape.panel)
        }
    }
}
