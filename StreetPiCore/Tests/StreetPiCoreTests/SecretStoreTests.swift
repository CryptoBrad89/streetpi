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

    func testAppPasswordRoundTripNeverDescribesThePassword() throws {
        let store = MemorySecretStore()
        let password = Data("fixture-not-a-real-password".utf8)
        try store.save(password, for: AppPassword.account)
        let loaded = try store.load(for: AppPassword.account)
        XCTAssertTrue(loaded == password)
        XCTAssertEqual(store.description, "MemorySecretStore(accounts: 1)")
        let request = AuthRequest(password: "fixture-not-a-real-password")
        XCTAssertEqual(String(describing: request), "AuthRequest(password: redacted)")
        XCTAssertFalse(String(describing: request).contains("fixture"))
        XCTAssertFalse(store.description.contains("fixture"))
    }
}
