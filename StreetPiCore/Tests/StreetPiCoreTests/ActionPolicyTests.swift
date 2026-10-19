import XCTest
@testable import StreetPiCore

final class ActionPolicyTests: XCTestCase {
    func testRefreshNeedsNothing() {
        XCTAssertEqual(ActionPolicy.confirmation(for: .refresh), .notRequired)
    }

    func testDestructiveActionsUseFaceIDAndSayWhatHappens() {
        let reboot = ActionPolicy.confirmation(for: .reboot)
        let shutdown = ActionPolicy.confirmation(for: .shutDown)
        let deletion = ActionPolicy.confirmation(for: .deleteFiles(count: 3))
        let kill = ActionPolicy.confirmation(for: .killProcess(named: "example-daemon"))

        for confirmation in [reboot, shutdown, deletion, kill] {
            XCTAssertTrue(confirmation.requiresFaceID)
            XCTAssertFalse(confirmation.explanation?.isEmpty ?? true)
        }

        XCTAssertEqual(
            reboot.explanation,
            "The Pi will restart. Ad blocking and the other house services will drop out for a few minutes."
        )
        XCTAssertEqual(
            shutdown.explanation,
            "The Pi will turn off and stay off until someone switches the power back on."
        )
        XCTAssertEqual(
            deletion.explanation,
            "This will permanently delete 3 items from the Pi. They cannot be undone."
        )
        XCTAssertEqual(
            ActionPolicy.confirmation(for: .deleteFiles(count: 1)).explanation,
            "This will permanently delete 1 item from the Pi. They cannot be undone."
        )
        XCTAssertEqual(
            kill.explanation,
            "example-daemon will be forced to quit. Anything it was doing stops immediately."
        )
    }

    func testWritesExplainThemselvesWithoutFaceID() {
        let stop = ActionPolicy.confirmation(for: .stopService(named: "Media"))
        let dns = ActionPolicy.confirmation(for: .changeDNSSettings)
        let pause = ActionPolicy.confirmation(for: .pauseAdBlocking(.untilTurnedBackOn))
        let resume = ActionPolicy.confirmation(for: .resumeAdBlocking)

        for confirmation in [stop, dns, pause, resume] {
            XCTAssertFalse(confirmation.requiresFaceID)
            XCTAssertFalse(confirmation.explanation?.isEmpty ?? true)
        }
        XCTAssertTrue(stop.explanation?.contains("Media will stop") ?? false)
        XCTAssertTrue(pause.explanation?.contains("whole house") ?? false)
        let timed = ActionPolicy.confirmation(for: .pauseAdBlocking(.fiveMinutes))
        XCTAssertFalse(timed.requiresFaceID)
        XCTAssertTrue(timed.explanation?.contains("5 minutes") ?? false)
        XCTAssertTrue(ActionPolicy.confirmation(for: .restartDNS).requiresFaceID)
        XCTAssertTrue(ActionPolicy.confirmation(for: .flushQueryLog).requiresFaceID)
        XCTAssertTrue(
            ActionPolicy.confirmation(for: .removeDNSEntry(.client, named: "Living room")).requiresFaceID
        )
        XCTAssertFalse(ActionPolicy.confirmation(for: .updateBlockLists).requiresFaceID)
    }

    func testCopyDoesNotNameAPersonOrAPrivateAddress() {
        let actions: [HouseholdAction] = [
            .reboot, .shutDown, .stopService(named: "Media"), .deleteFiles(count: 2),
            .changeDNSSettings, .killProcess(named: "example-daemon"),
            .pauseAdBlocking(.fiveMinutes), .resumeAdBlocking,
            .restartDNS, .flushQueryLog, .updateBlockLists,
            .removeDNSEntry(.domain, named: "ads.example.test"),
            .addDomain(named: "ads.example.test", blocked: true),
        ]
        for action in actions {
            let text = ActionPolicy.confirmation(for: action).explanation ?? ""
            XCTAssertFalse(text.localizedCaseInsensitiveContains("bradley"))
            XCTAssertFalse(text.localizedCaseInsensitiveContains("brandy"))
            XCTAssertFalse(text.localizedCaseInsensitiveContains("admin"))
            XCTAssertFalse(text.contains("192.168"))
        }
    }
}
