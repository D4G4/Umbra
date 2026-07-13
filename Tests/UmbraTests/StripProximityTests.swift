import XCTest
@testable import Umbra

final class StripProximityTests: XCTestCase {
    // A menu-bar-like strip: full width, 30 tall, along the top.
    private let strip = CGRect(x: 0, y: 1320, width: 3200, height: 30)

    func testOverStripIsOne() {
        XCTAssertEqual(StripProximity.value(mouse: CGPoint(x: 1600, y: 1335), frame: strip), 1)
    }

    func testJustBelowStripIsZero() {
        // One point below the strip's bottom edge — no reach zone, so 0.
        XCTAssertEqual(StripProximity.value(mouse: CGPoint(x: 1600, y: 1319), frame: strip), 0)
    }

    func testFarAwayIsZero() {
        XCTAssertEqual(StripProximity.value(mouse: CGPoint(x: 1600, y: 800), frame: strip), 0)
    }

    func testOutsideHorizontallyIsZero() {
        XCTAssertEqual(StripProximity.value(mouse: CGPoint(x: 4000, y: 1335), frame: strip), 0)
    }

    func testZeroFrameIsSafe() {
        XCTAssertEqual(StripProximity.value(mouse: .zero, frame: .zero), 0)
    }
}
