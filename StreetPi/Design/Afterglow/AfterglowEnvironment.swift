import SwiftUI

private struct AfterglowPaletteKey: EnvironmentKey {
    static let defaultValue = AfterglowPalette.night(contrast: .standard)
}

private struct AfterglowMotionGateKey: EnvironmentKey {
    static let defaultValue = AfterglowMotionGate(
        reduceMotion: false,
        still: false,
        reduceTransparency: false
    )
}

extension EnvironmentValues {
    var afterglowPalette: AfterglowPalette {
        get { self[AfterglowPaletteKey.self] }
        set { self[AfterglowPaletteKey.self] = newValue }
    }

    var afterglowGate: AfterglowMotionGate {
        get { self[AfterglowMotionGateKey.self] }
        set { self[AfterglowMotionGateKey.self] = newValue }
    }
}
