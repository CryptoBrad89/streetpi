import XCTest
@testable import StreetPiCore

final class RefreshPaceTests: XCTestCase {
    func testQuietPaceAndBackoff() {
        XCTAssertEqual(RefreshPace.waitSeconds(afterFailures: 0), 30)
        XCTAssertEqual(RefreshPace.waitSeconds(afterFailures: 1), 60)
        XCTAssertEqual(RefreshPace.waitSeconds(afterFailures: 2), 120)
        XCTAssertEqual(RefreshPace.waitSeconds(afterFailures: 3), 240)
        XCTAssertEqual(RefreshPace.waitSeconds(afterFailures: 4), 300)
        XCTAssertEqual(RefreshPace.waitSeconds(afterFailures: 9), 300)
    }

    func testPollerBacksOffWithoutAHost() async {
        let script = Script()
        let poller = HousePoller {
            try await script.next()
        }
        let first = await poller.tick()
        XCTAssertTrue(first.unreachable)
        XCTAssertEqual(first.waitSeconds, 60)
        XCTAssertNil(first.snapshot)
        let second = await poller.tick()
        XCTAssertTrue(second.unreachable)
        XCTAssertEqual(second.waitSeconds, 120)
        let third = await poller.tick()
        XCTAssertFalse(third.unreachable)
        XCTAssertEqual(third.waitSeconds, 30)
        XCTAssertEqual(third.snapshot, .healthyFixture)
        let described = String(describing: third)
        XCTAssertFalse(described.contains("192.168"))
    }

    func testUnreachableCopyStaysPlain() {
        XCTAssertEqual(HouseReadingCopy.unreachableTitle, PiholeProblem.offline.title)
        XCTAssertTrue(HouseReadingCopy.unreachableDetail.contains("Nothing was changed"))
        XCTAssertTrue(HouseReadingCopy.unreachableDetail.contains("try again"))
        XCTAssertFalse(HouseReadingCopy.unreachableDetail.contains("192.168"))
        XCTAssertFalse(HouseReadingCopy.unreachableDetail.localizedCaseInsensitiveContains("timeout"))
        XCTAssertTrue(HouseReadingCopy.emptyTitle.contains("Nothing"))
    }
}

private actor Script {
    private var misses = 2

    func next() throws -> HouseholdSnapshot {
        if misses > 0 {
            misses -= 1
            throw PiholeProblem.offline
        }
        return .healthyFixture
    }
}
