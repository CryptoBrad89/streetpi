import SwiftUI

enum AppearancePreference: String, CaseIterable, Identifiable {
    case system
    case dark
    case light

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .dark: "Dark"
        case .light: "Light"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .dark: .dark
        case .light: .light
        }
    }
}

enum DesignDirection: String, CaseIterable, Identifiable {
    case lampblack
    case harbor
    case porch

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lampblack: "Lampblack"
        case .harbor: "Harbor"
        case .porch: "Porch"
        }
    }

    var blurb: String {
        switch self {
        case .lampblack: "Quiet type on a warm black page."
        case .harbor: "Cool instruments and a hard grid."
        case .porch: "A softer card for the whole house."
        }
    }
}

enum AppSection: Equatable {
    case home
    case settings
}

enum PreferenceKey {
    static let appearance = "streetpi.appearance"
    static let direction = "streetpi.designDirection"
}
