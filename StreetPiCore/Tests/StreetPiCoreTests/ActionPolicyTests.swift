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

    func testFilterWritesExplainThemselvesWithoutFaceID() throws {
        let stop = ActionPolicy.confirmation(for: .stopService(named: "Media"))
        let pause = ActionPolicy.confirmation(for: .pauseAdBlocking(.fiveMinutes))
        let resume = ActionPolicy.confirmation(for: .resumeAdBlocking)
        let block = ActionPolicy.confirmation(for: .blockDomain(named: "ads.example.test"))
        let allow = ActionPolicy.confirmation(for: .allowDomain(named: "news.example.test"))
        let custom = try XCTUnwrap(PauseLength(seconds: 12 * 60))
        let customPause = ActionPolicy.confirmation(for: .pauseAdBlocking(custom))

        for confirmation in [stop, pause, resume, block, allow, customPause] {
            XCTAssertFalse(confirmation.requiresFaceID)
            XCTAssertFalse(confirmation.explanation?.isEmpty ?? true)
        }
        XCTAssertTrue(stop.explanation?.contains("Media will stop") ?? false)
        XCTAssertTrue(pause.explanation?.contains("5 minutes") ?? false)
        XCTAssertTrue(pause.explanation?.contains("turns itself back on") ?? false)
        XCTAssertTrue(customPause.explanation?.contains("12 minutes") ?? false)
        XCTAssertTrue(resume.explanation?.contains("turn back on") ?? false)
        XCTAssertEqual(block.explanation, "ads.example.test will be blocked for the whole house.")
        XCTAssertEqual(allow.explanation, "news.example.test will be allowed for the whole house.")
        XCTAssertFalse(ActionPolicy.confirmation(for: .signOutOfAdBlocker).requiresFaceID)
    }

    func testCopyDoesNotNameAPersonOrAPrivateAddress() throws {
        let custom = try XCTUnwrap(PauseLength(seconds: 120))
        let actions: [HouseholdAction] = [
            .reboot, .shutDown, .stopService(named: "Media"), .deleteFiles(count: 2),
            .killProcess(named: "example-daemon"),
            .pauseAdBlocking(.fiveMinutes), .pauseAdBlocking(custom), .resumeAdBlocking,
            .blockDomain(named: "ads.example.test"),
            .allowDomain(named: "news.example.test"),
            .signOutOfAdBlocker,
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
