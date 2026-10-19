import StreetPiCore
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

enum HouseScreen: Equatable {
    case ready(HouseholdSnapshot)
    case empty
    case failed

    func status(now: Date) -> PlainEnglishStatus {
        switch self {
        case .ready(let snapshot):
            StatusNarrator.narrate(snapshot, now: now)
        case .empty:
            PlainEnglishStatus(
                headline: HouseReadingCopy.emptyTitle,
                detail: HouseReadingCopy.emptyDetail,
                tone: .calm,
                linkLine: "No reading yet"
            )
        case .failed:
            PlainEnglishStatus(
                headline: HouseReadingCopy.unreachableTitle,
                detail: HouseReadingCopy.unreachableDetail,
                tone: .problem,
                linkLine: "Not connected"
            )
        }
    }

    var snapshot: HouseholdSnapshot? {
        if case .ready(let snapshot) = self {
            return snapshot
        }
        return nil
    }
}

enum AppSection: Hashable {
    case home
    case group(HouseGroup)
    case alerts
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
