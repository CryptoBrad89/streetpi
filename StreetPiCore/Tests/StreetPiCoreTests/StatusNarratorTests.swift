import XCTest
@testable import StreetPiCore

final class StatusNarratorTests: XCTestCase {
    private let now = Date.streetFixtureNow

    func testHealthyHomeIsCalm() {
        let status = StatusNarrator.narrate(.healthyFixture, now: now)
        XCTAssertEqual(status.headline, "Everything at home is running.")
        XCTAssertNil(status.detail)
        XCTAssertEqual(status.tone, .calm)
        XCTAssertEqual(status.linkLine, "On the home network")
    }

    func testOneServiceDownNamesIt() {
        var snapshot = HouseholdSnapshot.healthyFixture
        snapshot.services[0].state = .notResponding
        let status = StatusNarrator.narrate(snapshot, now: now)
        XCTAssertEqual(status.headline, "Pi-hole is not responding.")
        XCTAssertEqual(status.tone, .problem)
        XCTAssertNil(status.detail)
    }

    func testSeveralServicesDownStayPlural() {
        var snapshot = HouseholdSnapshot.healthyFixture
        snapshot.services[0].state = .notResponding
        snapshot.services[2].state = .notResponding
        let status = StatusNarrator.narrate(snapshot, now: now)
        XCTAssertEqual(status.headline, "A few things at home need a look.")
        XCTAssertEqual(status.detail, "Pi-hole and Home Assistant are not responding.")
        XCTAssertEqual(status.tone, .problem)
    }

    func testTemperatureThresholds() {
        var warm = HouseholdSnapshot.healthyFixture
        warm.machine?.temperatureCelsius = 72
        let warmStatus = StatusNarrator.narrate(warm, now: now)
        XCTAssertEqual(warmStatus.headline, "The Pi is warmer than usual.")
        XCTAssertEqual(warmStatus.tone, .attention)

        var hot = HouseholdSnapshot.healthyFixture
        hot.machine?.temperatureCelsius = 81
        let hotStatus = StatusNarrator.narrate(hot, now: now)
        XCTAssertEqual(hotStatus.headline, "The Pi is too hot.")
        XCTAssertEqual(hotStatus.tone, .problem)
    }

    func testDiskAndMemoryAttention() {
        var snapshot = HouseholdSnapshot.healthyFixture
        snapshot.machine?.diskUsedFraction = 0.94
        snapshot.machine?.memoryUsedFraction = 0.95
        let status = StatusNarrator.narrate(snapshot, now: now)
        XCTAssertEqual(status.headline, "The Pi's disk is almost full.")
        XCTAssertEqual(status.detail, "The Pi is low on memory.")
        XCTAssertEqual(status.tone, .attention)
    }

    func testBlockingPaused() {
        var snapshot = HouseholdSnapshot.healthyFixture
        snapshot.dns?.blockingEnabled = false
        let status = StatusNarrator.narrate(snapshot, now: now)
        XCTAssertEqual(status.headline, "Ad blocking is paused.")
        XCTAssertEqual(status.tone, .attention)
    }

    func testAwayHealthyMentionsAge() {
        var snapshot = HouseholdSnapshot.healthyFixture
        let cachedAt = now.addingTimeInterval(-12 * 60)
        snapshot.link = .away(cachedAt: cachedAt)
        snapshot.capturedAt = cachedAt
        let status = StatusNarrator.narrate(snapshot, now: now)
        XCTAssertEqual(status.headline, "Everything at home is running.")
        XCTAssertEqual(status.detail, "You're away from home. This reading is from 12 minutes ago.")
        XCTAssertEqual(status.linkLine, "Away · 12 minutes ago")
        XCTAssertEqual(status.tone, .calm)
    }

    func testProblemWhileAwayKeepsTheProblem() {
        let status = StatusNarrator.narrate(.awayTroubleFixture, now: now)
        XCTAssertEqual(status.headline, "Pi-hole is not responding.")
        XCTAssertEqual(status.tone, .problem)
        XCTAssertEqual(status.detail, "You're away from home. This reading is from 12 minutes ago.")
    }

    func testAgePhrases() {
        XCTAssertEqual(AgePhrase.english(from: now.addingTimeInterval(-30), to: now), "just now")
        XCTAssertEqual(AgePhrase.english(from: now.addingTimeInterval(-5 * 60), to: now), "5 minutes ago")
        XCTAssertEqual(AgePhrase.english(from: now.addingTimeInterval(-2 * 3_600), to: now), "2 hours ago")
        XCTAssertEqual(AgePhrase.english(from: now.addingTimeInterval(-26 * 3_600), to: now), "yesterday")
        XCTAssertEqual(AgePhrase.english(from: now.addingTimeInterval(-3 * 86_400), to: now), "3 days ago")
    }

    func testPorchLinesForAQuietHouse() {
        XCTAssertEqual(
            HouseholdVoice.porchLines(.healthyFixture),
            [
                "Ads are being blocked.",
                "The Pi is cool and quiet.",
                "Home Assistant is up.",
            ]
        )
    }

    func testMissingQueryCountsStayNil() {
        XCTAssertNil(HouseholdSnapshot.healthyFixture.dns?.queriesToday)
        XCTAssertNil(HouseholdSnapshot.healthyFixture.dns?.blockedToday)
    }
}
