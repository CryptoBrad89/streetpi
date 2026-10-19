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

    func testHome() {
        assertMatrix(section: .home, screen: .ready(house), testName: "home")
    }

    func testAway() {
        assertMatrix(section: .home, screen: .ready(.awayFreshFixture), testName: "away")
    }

    func testError() {
        assertMatrix(section: .home, screen: .failed, testName: "error")
    }

    func testStale() {
        assertMatrix(section: .home, screen: .ready(.staleFixture), testName: "stale")
    }

    func testEmpty() {
        assertMatrix(section: .home, screen: .empty, testName: "empty")
    }

    func testAdBlocker() {
        assertMatrix(section: .group(.adBlockerAndDNS), screen: .ready(house), testName: "ad-blocker")
    }

    func testPiHealth() {
        assertMatrix(section: .group(.piHealth), screen: .ready(house), testName: "pi-health")
    }

    func testSettings() {
        assertMatrix(section: .settings, screen: .ready(house), testName: "settings")
    }

    func testIntro() {
        for scheme in [ColorScheme.dark, ColorScheme.light] {
            for size in SnapshotScale.allCases {
                for device in SnapshotDevice.allCases {
                    let view = IntroView(theme: .house(scheme), animatesIn: false) {}
                        .environment(\.colorScheme, scheme)
                        .environment(\.dynamicTypeSize, size.dynamicType)
                        .environment(\.streetPiStill, true)
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

    private func assertMatrix(section: AppSection, screen: HouseScreen, testName: String) {
        for scheme in [ColorScheme.dark, ColorScheme.light] {
            for size in SnapshotScale.allCases {
                for device in SnapshotDevice.allCases {
                    let view = AppShell(
                        section: section,
                        appearance: scheme == .dark ? .dark : .light,
                        screen: screen,
                        now: now,
                        onSection: { _ in },
                        onAppearance: { _ in }
                    )
                    .environment(\.colorScheme, scheme)
                    .environment(\.dynamicTypeSize, size.dynamicType)
                    .environment(\.streetPiStill, true)
                    assertSnapshot(
                        of: view,
                        as: .image(
                            layout: .device(config: device.config),
                            traits: traits(scheme: scheme, size: size)
                        ),
                        named: "\(name(scheme))-\(size.rawValue)-\(device.rawValue)",
                        testName: testName
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
