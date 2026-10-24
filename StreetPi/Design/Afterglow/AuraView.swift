import simd
import StreetPiCore
import SwiftUI

/// Status-tinted glow. This is the only gradient in the design system.
/// `streetPiStill` and Reduce Motion paint a fixed radial glow so snapshots
/// never render `MeshGradient` or `TimelineView`.
struct AuraView: View {
    var tone: PlainEnglishStatus.Tone

    @Environment(\.afterglowPalette) private var palette
    @Environment(\.afterglowGate) private var gate

    var body: some View {
        Group {
            if breathes {
                TimelineView(.animation(minimumInterval: 1.0 / 8.0, paused: false)) { timeline in
                    let phase = timeline.date.timeIntervalSinceReferenceDate
                        .truncatingRemainder(dividingBy: AfterglowMotion.breathe) / AfterglowMotion.breathe
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: points(phase: phase),
                        colors: meshColors
                    )
                }
            } else {
                RadialGradient(
                    colors: palette.auraColors(for: tone),
                    center: UnitPoint(x: 0.5, y: 0.42),
                    startRadius: 4,
                    endRadius: 240
                )
            }
        }
        .accessibilityHidden(true)
    }

    private var breathes: Bool {
        gate.holdsMotion && !ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    private var meshColors: [Color] {
        let ground = palette.ground
        let lead: Color
        let mid: Color
        switch tone {
        case .calm:
            lead = palette.auraHoney
            mid = palette.auraEmber
        case .attention:
            lead = palette.attention
            mid = palette.auraHoney
        case .problem:
            lead = palette.problem
            mid = palette.auraRose
        }
        return [
            ground, mid.opacity(0.40), ground,
            lead.opacity(0.65), lead, mid.opacity(0.75),
            ground, palette.auraRose.opacity(tone == .calm ? 0.45 : 0.25), ground,
        ]
    }

    private func points(phase: Double) -> [SIMD2<Float>] {
        let drift = Float(sin(phase * 2 * .pi)) * 0.04
        return [
            SIMD2(0, 0), SIMD2(0.5, 0), SIMD2(1, 0),
            SIMD2(0, 0.5 + drift), SIMD2(0.5 + drift, 0.48 - drift), SIMD2(1, 0.5 - drift),
            SIMD2(0, 1), SIMD2(0.5, 1), SIMD2(1, 1),
        ]
    }
}
