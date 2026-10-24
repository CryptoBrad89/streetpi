import SwiftUI

/// Word-line blur that sharpens as `progress` moves from 0 to 1.
struct BlurRevealRenderer: TextRenderer {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        let clamped = min(max(progress, 0), 1)
        for line in layout {
            for run in line {
                context.drawLayer { layer in
                    layer.opacity = Double(clamped)
                    layer.addFilter(.blur(radius: (1 - clamped) * 6))
                    layer.draw(run)
                }
            }
        }
    }
}
