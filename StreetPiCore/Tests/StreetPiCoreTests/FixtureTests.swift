import XCTest
@testable import StreetPiCore

final class FixtureTests: XCTestCase {
    func testHealthyJSONMatchesTheSwiftFixture() throws {
        let decoded = try FixtureBook.snapshot(named: "healthy-home")
        XCTAssertEqual(decoded, .healthyFixture)
    }

    func testAwayJSONMatchesTheSwiftFixture() throws {
        let decoded = try FixtureBook.snapshot(named: "away-trouble")
        XCTAssertEqual(decoded, .awayTroubleFixture)
    }

    func testFixturePlanNeverPointsAtARealHost() {
        for endpoint in ConnectionPlan.fixture.endpoints {
            XCTAssertEqual(endpoint.host, "fixture.local")
            XCTAssertFalse(endpoint.host.contains("192.168"))
        }
    }

    func testReadingText() {
        XCTAssertEqual(ReadingText.percent(0.18), "18%")
        XCTAssertEqual(ReadingText.celsius(47.2), "47°")
        XCTAssertEqual(ReadingText.warmth(47.2), "Cool")
        XCTAssertEqual(ReadingText.uptime(1_036_800), "Up 12 days")
        XCTAssertEqual(
            ReadingText.stateWord(for: HouseholdSnapshot.healthyFixture.services[0]),
            "Blocking"
        )
        XCTAssertEqual(
            ReadingText.stateWord(for: HouseholdSnapshot.healthyFixture.services[1]),
            "Answering"
        )
    }
}
