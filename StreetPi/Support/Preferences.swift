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

enum AppSection: Equatable {
    case home
    case settings
}

enum PreferenceKey {
    static let appearance = "streetpi.appearance"
}

private struct StreetStillKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// Snapshot stand-in for Reduce Motion. The system key is read-only in the iOS 26 SDK.
    var streetPiStill: Bool {
        get { self[StreetStillKey.self] }
        set { self[StreetStillKey.self] = newValue }
    }
}
