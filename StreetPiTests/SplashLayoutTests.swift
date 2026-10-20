import UIKit
import XCTest
@testable import StreetPi

final class SplashLayoutTests: XCTestCase {
    private let media = CGSize(width: 854, height: 480)

    func testPhoneFills() {
        XCTAssertEqual(SplashLayout.fit(viewSize: CGSize(width: 320, height: 568), mediaSize: media), .fill)
        XCTAssertEqual(SplashLayout.fit(viewSize: CGSize(width: 390, height: 844), mediaSize: media), .fill)
        XCTAssertEqual(SplashLayout.fit(viewSize: CGSize(width: 428, height: 926), mediaSize: media), .fill)
    }

    func testPadPortraitLetterboxes() {
        XCTAssertEqual(SplashLayout.fit(viewSize: CGSize(width: 834, height: 1194), mediaSize: media), .letterbox)
    }

    func testPadLandscapeFills() {
        XCTAssertEqual(SplashLayout.fit(viewSize: CGSize(width: 1194, height: 834), mediaSize: media), .fill)
    }

    func testSplashVideoIsBundled() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: SplashLayout.resourceName, withExtension: "mp4"))
        let data = try Data(contentsOf: url)
        XCTAssertGreaterThan(data.count, 1_000_000)
    }

    func testClosingFrameIsTheVideoSize() throws {
        let image = try SplashFixture.closing()
        XCTAssertEqual(image.size, media)
    }
}

enum SplashFixture {
    static func opening() throws -> UIImage {
        let bundle = Bundle(for: SplashLayoutTests.self)
        let url = try XCTUnwrap(bundle.url(forResource: "StreetPiSplashStart", withExtension: "png"))
        let data = try Data(contentsOf: url)
        return try XCTUnwrap(UIImage(data: data, scale: 1))
    }

    static func closing() throws -> UIImage {
        try XCTUnwrap(UIImage(named: SplashLayout.endImageName, in: .main, compatibleWith: nil))
    }
}
