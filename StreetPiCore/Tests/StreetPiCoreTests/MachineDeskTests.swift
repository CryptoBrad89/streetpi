import XCTest
@testable import StreetPiCore

final class MachineDeskTests: XCTestCase {
    func testFixtureStaysOffTheRealNetwork() {
        let desk = MachineDesk.houseFixture
        XCTAssertEqual(desk.host, "fixture.local")
        XCTAssertFalse(desk.host.contains("192.168"))
        XCTAssertEqual(desk.series.count, 4)
        XCTAssertEqual(desk.series.first?.points.count, 24)
        XCTAssertTrue(desk.alerts.isEmpty)
        let paths = NetdataAPI.routes.map(\.path) + [StatusPageAPI.route.path]
        XCTAssertTrue(paths.allSatisfy { !$0.contains("://") && !$0.contains("192.168") })
        XCTAssertTrue(paths.contains("/api/v1/alarms"))
        XCTAssertTrue(paths.contains("/api/v3/data"))
        XCTAssertTrue(paths.contains("/api/status-page/house"))
        XCTAssertTrue(NetdataAPI.chartFamilies.contains("system.uptime"))
        XCTAssertTrue(NetdataAPI.chartFamilies.contains("cgroup.docker"))
    }

    func testStatusIsAReading() {
        let desk = MachineDesk.houseFixture
        XCTAssertEqual(desk.services.map(\.detail), ["Up", "Up", "Up"])
        XCTAssertEqual(desk.containers.map(\.detail), ["Running", "Running"])
        XCTAssertFalse(desk.services.contains { $0.detail.contains("Stop") })
    }
}
