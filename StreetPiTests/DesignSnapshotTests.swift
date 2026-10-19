import SnapshotTesting
import StreetPiCore
import SwiftUI
import UIKit
import XCTest
@testable import StreetPi

@MainActor
final class DesignSnapshotTests: XCTestCase {
    private let now = Date.streetFixtureNow
    private let house = HouseholdSnapshot.healthyFixture

    func testLampblack() {
        assertHome(.lampblack)
    }

    func testHarbor() {
        assertHome(.harbor)
    }

    func testPorch() {
        assertHome(.porch)
    }

    func testSettings() {
        assertMatrix(direction: .lampblack, section: .settings)
    }

    func testIntro() {
        for scheme in [ColorScheme.dark, ColorScheme.light] {
            for size in SnapshotScale.allCases {
                for device in SnapshotDevice.allCases {
                    let theme = DesignDirection.lampblack.theme(scheme)
                    let view = IntroView(theme: theme, animatesIn: false) {}
                        .environment(\.colorScheme, scheme)
                        .environment(\.dynamicTypeSize, size.dynamicType)
                        .environment(\.accessibilityReduceMotion, true)
                    assertSnapshot(
                        of: view,
                        as: .image(
                            layout: .device(config: device.config),
                            traits: traits(scheme: scheme, size: size)
                        ),
                        named: "\(name(scheme))-\(size.rawValue)-\(device.rawValue)"
                    )
                }
            }
        }
    }

    private func assertHome(_ direction: DesignDirection) {
        assertMatrix(direction: direction, section: .home)
    }

    private func assertMatrix(direction: DesignDirection, section: AppSection) {
        let sectionName = section == .home ? "home" : "settings"
        for scheme in [ColorScheme.dark, ColorScheme.light] {
            for size in SnapshotScale.allCases {
                for device in SnapshotDevice.allCases {
                    let view = AppShell(
                        section: section,
                        direction: direction,
                        appearance: scheme == .dark ? .dark : .light,
                        snapshot: house,
                        now: now,
                        onSection: { _ in },
                        onAppearance: { _ in },
                        onDirection: { _ in }
                    )
                    .environment(\.colorScheme, scheme)
                    .environment(\.dynamicTypeSize, size.dynamicType)
                    .environment(\.accessibilityReduceMotion, true)
                    assertSnapshot(
                        of: view,
                        as: .image(
                            layout: .device(config: device.config),
                            traits: traits(scheme: scheme, size: size)
                        ),
                        named: "\(name(scheme))-\(size.rawValue)-\(device.rawValue)",
                        testName: "\(direction.rawValue)-\(sectionName)"
                    )
                }
            }
        }
    }

    private func traits(scheme: ColorScheme, size: SnapshotScale) -> UITraitCollection {
        UITraitCollection(traitsFrom: [
            UITraitCollection(userInterfaceStyle: scheme == .dark ? .dark : .light),
            UITraitCollection(preferredContentSizeCategory: size.category),
        ])
    }

    private func name(_ scheme: ColorScheme) -> String {
        scheme == .dark ? "dark" : "light"
    }
}

private enum SnapshotScale: String, CaseIterable {
    case `default`
    case largest

    var dynamicType: DynamicTypeSize {
        switch self {
        case .default: .large
        case .largest: .accessibility5
        }
    }

    var category: UIContentSizeCategory {
        switch self {
        case .default: .large
        case .largest: .accessibilityExtraExtraExtraLarge
        }
    }
}

private enum SnapshotDevice: String, CaseIterable {
    case smallPhone
    case largePhone
    case pad

    var config: ViewImageConfig {
        switch self {
        case .smallPhone: .iPhoneSe
        case .largePhone: .iPhone13ProMax
        case .pad: .iPadPro11
        }
    }
}
