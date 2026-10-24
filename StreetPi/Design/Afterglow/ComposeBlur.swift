import SwiftUI

struct ComposeBlur: ViewModifier {
    var enabled: Bool
    var progress: CGFloat

    func body(content: Content) -> some View {
        if enabled {
            content.textRenderer(BlurRevealRenderer(progress: progress))
        } else {
            content
        }
    }
}
