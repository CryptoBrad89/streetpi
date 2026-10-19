import XCTest
@testable import StreetPiCore

final class DNSDeskTests: XCTestCase {
    func testLoggingOffLeavesTheLogAndTopListsEmpty() {
        let desk = DNSDesk.houseFixture
        XCTAssertFalse(desk.queryLoggingEnabled)
        XCTAssertFalse(desk.configWritesAllowed)
        XCTAssertFalse(desk.chartIsSample)
        XCTAssertTrue(desk.day.isEmpty)
        XCTAssertTrue(desk.queries.isEmpty)
        XCTAssertTrue(desk.topClients.isEmpty)
        XCTAssertEqual(DNSCopy.queryLogTitle, "Nothing to show.")
        XCTAssertTrue(DNSCopy.queryLogDetail.contains("Query logging is off"))
        XCTAssertTrue(DNSCopy.chartEmptyDetail.contains("no picture of the last day"))
    }

    func testFixtureNamesStayOnTheSampleHost() {
        let desk = DNSDesk.houseFixture
        XCTAssertTrue(desk.lists.allSatisfy { $0.host == "fixture.local" })
        let blob = [
            desk.clients.map(\.name),
            desk.domains.map(\.name),
            desk.localNames.map(\.name),
            desk.lists.map(\.host),
        ].flatMap { $0 }.joined(separator: " ")
        XCTAssertFalse(blob.contains("192.168"))
        XCTAssertFalse(blob.localizedCaseInsensitiveContains("bradley"))
        XCTAssertFalse(blob.localizedCaseInsensitiveContains("brandy"))
    }

    func testRoutesMatchTheV6ShapeAndNeverNameAHost() {
        let paths = DNSAPI.routes.map(\.path)
        XCTAssertTrue(paths.contains("/api/auth"))
        XCTAssertTrue(paths.contains("/api/stats/summary"))
        XCTAssertTrue(paths.contains("/api/history"))
        XCTAssertTrue(paths.contains("/api/dns/blocking"))
        XCTAssertTrue(paths.contains("/api/queries"))
        XCTAssertTrue(paths.contains("/api/action/gravity"))
        let config = DNSAPI.routes.filter { $0.path == "/api/config" }
        XCTAssertEqual(config.count, 2)
        XCTAssertTrue(config.allSatisfy(\.needsConfigAccess))
        XCTAssertTrue(DNSAPI.routes.allSatisfy { !$0.path.contains("192.168") && !$0.path.contains("://") })
    }

    func testPauseAndRemovalStayOnTheFixture() {
        let paused = DNSDesk.houseFixture.applying(.pauseAdBlocking(.fiveMinutes))
        XCTAssertFalse(paused.blocking.enabled)
        XCTAssertEqual(paused.blocking.pause, .fiveMinutes)
        XCTAssertFalse(paused.queryLoggingEnabled)
        let removed = paused.applying(.removeDNSEntry(.domain, named: "ads.example.test"))
        XCTAssertFalse(removed.domains.contains { $0.name == "ads.example.test" })
        let added = removed.applying(.addBlockList(named: "Extra list"))
        XCTAssertEqual(added.lists.last?.host, "fixture.local")
    }

    func testLoggingOnFillsTheChartAndLocalNamesStayLockedUntilAllowed() {
        let live = DNSDesk.loggingOnFixture
        XCTAssertTrue(live.queryLoggingEnabled)
        XCTAssertTrue(live.configWritesAllowed)
        XCTAssertEqual(live.day.count, 24)
        XCTAssertFalse(live.queries.isEmpty)
        let locked = DNSDesk.houseFixture.applying(.addLocalName(named: "camera.fixture.local"))
        XCTAssertFalse(locked.localNames.contains { $0.name == "camera.fixture.local" })
        let saved = live.applying(.addLocalName(named: "camera.fixture.local"))
        XCTAssertTrue(saved.localNames.contains { $0.name == "camera.fixture.local" })
    }

    func testPiSideAsksStayUnapplied() {
        XCTAssertTrue(PiSideAsk.queryLogging.contains("will not change"))
        XCTAssertTrue(PiSideAsk.queryLogging.contains("maxDBdays=0"))
        XCTAssertTrue(PiSideAsk.localNames.contains("app_sudo=true"))
        XCTAssertTrue(PiSideAsk.localNames.contains("will not change"))
        XCTAssertFalse(DNSDesk.houseFixture.queryLoggingEnabled)
    }

    func testPagesCoverTheDesk() {
        let pages = DNSShelf.allCases.flatMap(\.pages)
        XCTAssertEqual(Set(pages), Set(DNSPage.allCases))
        XCTAssertEqual(DNSPage.today.title, "Today")
        XCTAssertTrue(DNSPage.queryLog.blurb.contains("saved"))
    }
}
