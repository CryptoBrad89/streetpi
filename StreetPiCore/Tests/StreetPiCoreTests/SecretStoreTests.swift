import XCTest
@testable import StreetPiCore

final class SecretStoreTests: XCTestCase {
    func testMemoryStoreRoundTripDoesNotDescribeTheSecret() throws {
        let store = MemorySecretStore()
        let secret = Data("fixture-not-a-real-secret".utf8)
        try store.save(secret, for: "pi-hole-app-password")
        XCTAssertEqual(try store.load(for: "pi-hole-app-password"), secret)
        XCTAssertFalse(store.description.contains("fixture-not-a-real-secret"))
        XCTAssertFalse(store.description.contains("pi-hole-app-password"))
        XCTAssertEqual(store.description, "MemorySecretStore(accounts: 1)")
        try store.delete(for: "pi-hole-app-password")
        XCTAssertNil(try store.load(for: "pi-hole-app-password"))
    }
}
