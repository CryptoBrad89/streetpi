import StreetPiCore
import SwiftUI

enum Rhythm {
    static let tight: CGFloat = 6
    static let line: CGFloat = 12
    static let block: CGFloat = 22
    static let page: CGFloat = 28
}

struct StreetTheme: Equatable {
    var background: Color
    var surface: Color
    var ink: Color
    var secondary: Color
    var tertiary: Color
    var accent: Color
    var calm: Color
    var attention: Color
    var problem: Color
    var hairline: Color

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
}

enum StreetColor {
    static func rgb(_ hex: UInt32) -> Color {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}

extension StreetTheme {
    static func house(_ scheme: ColorScheme) -> StreetTheme {
        switch scheme {
        case .light:
            StreetTheme(
                background: StreetColor.rgb(0xF3EBDF),
                surface: StreetColor.rgb(0xFFF8F0),
                ink: StreetColor.rgb(0x2A221C),
                secondary: StreetColor.rgb(0x6A5B4E),
                tertiary: StreetColor.rgb(0x5C5146),
                accent: StreetColor.rgb(0xA24E28),
                calm: StreetColor.rgb(0x3E6B40),
                attention: StreetColor.rgb(0x8A4E12),
                problem: StreetColor.rgb(0x9E2F1C),
                hairline: StreetColor.rgb(0xE4D5C4)
            )
        default:
            StreetTheme(
                background: StreetColor.rgb(0x1A1614),
                surface: StreetColor.rgb(0x2C2420),
                ink: StreetColor.rgb(0xF7F0E7),
                secondary: StreetColor.rgb(0xCDBEAF),
                tertiary: StreetColor.rgb(0xA89888),
                accent: StreetColor.rgb(0xE3926A),
                calm: StreetColor.rgb(0xB7CFA8),
                attention: StreetColor.rgb(0xE2B07A),
                problem: StreetColor.rgb(0xFF8A73),
                hairline: StreetColor.rgb(0x3A312C)
            )
        }
    }
}
