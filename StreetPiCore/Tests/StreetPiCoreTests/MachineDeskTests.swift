import XCTest
@testable import StreetPiCore

final class MachineDeskTests: XCTestCase {
    func testFixtureStaysOffTheRealNetwork() {
        let desk = MachineDesk.houseFixture
        XCTAssertEqual(desk.host, "fixture.local")
        XCTAssertFalse(desk.host.contains("192.168"))
        XCTAssertEqual(desk.cpu.count, 24)
        XCTAssertTrue(desk.terminalTranscript.contains("fixture.local"))
        XCTAssertTrue(NetdataAPI.routes.allSatisfy { !$0.path.contains("://") && !$0.path.contains("192.168") })
        XCTAssertTrue(NetdataAPI.routes.map(\.path).contains("/api/v1/alarms"))
    }

    func testHostPinRejectsADifferentKey() {
        let pin = MachineDesk.houseFixture.hostPin
        XCTAssertTrue(HostPin.accepts(presented: pin, pinned: pin))
        XCTAssertFalse(HostPin.accepts(presented: "SHA256:other", pinned: pin))
        XCTAssertFalse(HostPin.accepts(presented: pin, pinned: ""))
    }

    func testExportAndDestructiveActions() {
        let csv = ActivityExport.csv(MachineDesk.houseFixture.activity)
        XCTAssertTrue(csv.hasPrefix("when,what"))
        XCTAssertTrue(csv.contains("The weekly copy succeeded."))
        let killed = MachineDesk.houseFixture.applying(.killProcess(named: "House filter"))
        XCTAssertFalse(killed.processes.contains { $0.name == "House filter" })
        XCTAssertTrue(ActionPolicy.confirmation(for: .reboot).requiresFaceID)
        XCTAssertTrue(ActionPolicy.confirmation(for: .removeCron(named: "Weekly copy")).requiresFaceID)
        XCTAssertFalse(ActionPolicy.confirmation(for: .runBackup).requiresFaceID)
        XCTAssertFalse(ActionPolicy.confirmation(for: .installUpdates).requiresFaceID)
    }

    func testPrivateKeyAccountIsNotThePinAndAsksStayUnapplied() {
        XCTAssertNotEqual(DeviceSecret.privateKeyAccount, HostPin.account)
        XCTAssertTrue(PiSideAsk.sshUser.contains("will not create the user"))
        XCTAssertTrue(PiSideAsk.sudoers.contains("will not write sudoers"))
        XCTAssertTrue(PiSideAsk.noAgent.contains("Do not install"))
        XCTAssertTrue(PiSideAsk.netdata.contains("/api/v3/data"))
    }

    func testSecretDescriptionStaysRedacted() throws {
        let store = MemorySecretStore()
        let secret = Data("fixture-not-a-real-key".utf8)
        try store.save(secret, for: DeviceSecret.privateKeyAccount)
        XCTAssertTrue(try store.load(for: DeviceSecret.privateKeyAccount) == secret)
        XCTAssertFalse(store.description.contains("fixture"))
        XCTAssertFalse(String(describing: store).contains("key"))
    }
}
