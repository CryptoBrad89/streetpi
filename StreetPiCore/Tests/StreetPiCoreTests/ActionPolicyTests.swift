import XCTest
@testable import StreetPiCore

final class ActionPolicyTests: XCTestCase {
    func testRefreshNeedsNothing() {
        XCTAssertEqual(ActionPolicy.confirmation(for: .refresh), .notRequired)
    }

    func testDestructiveActionsUseFaceIDAndSayWhatHappens() {
        let restart = ActionPolicy.confirmation(for: .restartDNS)
        let flush = ActionPolicy.confirmation(for: .flushQueryLog)
        let removal = ActionPolicy.confirmation(for: .removeDNSEntry(.client, named: "Living room"))

        for confirmation in [restart, flush, removal] {
            XCTAssertTrue(confirmation.requiresFaceID)
            XCTAssertFalse(confirmation.explanation?.isEmpty ?? true)
        }

        XCTAssertEqual(
            restart.explanation,
            "DNS will restart. Devices may briefly fail to look up names."
        )
        XCTAssertEqual(
            flush.explanation,
            "The saved lookup history will be erased. This cannot be undone."
        )
        XCTAssertEqual(
            removal.explanation,
            "Living room will be removed for the whole house. This cannot be undone."
        )
    }

    func testWritesExplainThemselvesWithoutFaceID() {
        let dns = ActionPolicy.confirmation(for: .changeDNSSettings)
        let pause = ActionPolicy.confirmation(for: .pauseAdBlocking(.untilTurnedBackOn))
        let resume = ActionPolicy.confirmation(for: .resumeAdBlocking)

        for confirmation in [dns, pause, resume] {
            XCTAssertFalse(confirmation.requiresFaceID)
            XCTAssertFalse(confirmation.explanation?.isEmpty ?? true)
        }
        XCTAssertTrue(pause.explanation?.contains("whole house") ?? false)
        let timed = ActionPolicy.confirmation(for: .pauseAdBlocking(.fiveMinutes))
        XCTAssertFalse(timed.requiresFaceID)
        XCTAssertTrue(timed.explanation?.contains("5 minutes") ?? false)
        XCTAssertFalse(ActionPolicy.confirmation(for: .updateBlockLists).requiresFaceID)
    }

    func testCopyDoesNotNameAPersonOrAPrivateAddress() {
        let actions: [HouseholdAction] = [
            .changeDNSSettings,
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
