import StreetPiCore
import SwiftUI

struct AfterglowPalette: Equatable {
    var ground: Color
    var panel: Color
    var panelRaised: Color
    var hairline: Color
    var hairlineInteractive: Color
    var ink: Color
    var secondary: Color
    var tertiary: Color
    var ember: Color
    var calm: Color
    var attention: Color
    var problem: Color
    var auraEmber: Color
    var auraHoney: Color
    var auraRose: Color

    func tone(_ tone: PlainEnglishStatus.Tone) -> Color {
        switch tone {
        case .calm:
            calm
        case .attention:
            attention
        case .problem:
            problem
        }
    }

    func auraColors(for tone: PlainEnglishStatus.Tone) -> [Color] {
        switch tone {
        case .calm:
            [auraHoney, auraEmber, auraRose.opacity(0.45), ground]
        case .attention:
            [attention, auraHoney, ground]
        case .problem:
            [problem, auraRose, ground]
        }
    }

    static func resolve(_ scheme: ColorScheme, contrast: ColorSchemeContrast) -> AfterglowPalette {
        switch scheme {
        case .light:
            daylight(contrast: contrast)
        default:
            night(contrast: contrast)
        }
    }

    static func night(contrast: ColorSchemeContrast) -> AfterglowPalette {
        let strong = contrast == .increased
        return AfterglowPalette(
            ground: StreetColor.rgb(0x0B0A09),
            panel: StreetColor.rgb(0x141210),
            panelRaised: StreetColor.rgb(0x1C1916),
            hairline: Color.white.opacity(strong ? 0.24 : 0.08),
            hairlineInteractive: Color.white.opacity(strong ? 0.24 : 0.16),
            ink: StreetColor.rgb(0xF5EFE8),
            secondary: StreetColor.rgb(0xA79D93),
            tertiary: StreetColor.rgb(0x6E655D),
            ember: StreetColor.rgb(0xFF9A5C),
            calm: StreetColor.rgb(0x8FD3A8),
            attention: StreetColor.rgb(0xF2B65A),
            problem: StreetColor.rgb(0xFF6B5E),
            auraEmber: StreetColor.rgb(0xFF8A4C),
            auraHoney: StreetColor.rgb(0xFFC27A),
            auraRose: StreetColor.rgb(0xE8707A)
        )
    }

    static func daylight(contrast: ColorSchemeContrast) -> AfterglowPalette {
        let strong = contrast == .increased
        let ink = StreetColor.rgb(0x211A15)
        return AfterglowPalette(
            ground: StreetColor.rgb(0xF6F1EA),
            panel: Color.white.opacity(0.70),
            panelRaised: StreetColor.rgb(0xFFFDF9),
            hairline: ink.opacity(strong ? 0.24 : 0.10),
            hairlineInteractive: ink.opacity(strong ? 0.24 : 0.16),
            ink: ink,
            secondary: StreetColor.rgb(0x5E5248),
            tertiary: StreetColor.rgb(0x82766B),
            ember: StreetColor.rgb(0xC2541F),
            calm: StreetColor.rgb(0x2F6B47),
            attention: StreetColor.rgb(0x8A5410),
            problem: StreetColor.rgb(0xA3291B),
            auraEmber: StreetColor.rgb(0xE7A27A),
            auraHoney: StreetColor.rgb(0xF6D7B4),
            auraRose: StreetColor.rgb(0xE8B4AE)
        )
    }
}
