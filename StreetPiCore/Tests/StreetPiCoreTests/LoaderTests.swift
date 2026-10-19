import XCTest
@testable import StreetPiCore

final class LoaderTests: XCTestCase {
    func testLoaderComposesFixtureClients() async throws {
        let loader = HouseholdStatusLoader.healthyFixture()
        let snapshot = try await loader.load()
        XCTAssertEqual(snapshot, .healthyFixture)
        XCTAssertEqual(FixtureLinkDetector(link: .homeNetwork).currentLink(), .homeNetwork)
    }
}
