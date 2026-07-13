import XCTest
@testable import Umbra

final class MenuBarGeometryTests: XCTestCase {
    func testMenuBarHeightMatchesGapAboveVisibleFrame() {
        // The 30pt case observed on the dev machine.
        let frame = CGRect(x: 0, y: 0, width: 3440, height: 1440)
        let visible = CGRect(x: 0, y: 0, width: 3440, height: 1410)
        XCTAssertEqual(MenuBarGeometry.menuBarHeight(frame: frame, visibleFrame: visible), 30)
    }

    func testMenuBarHeightIsZeroWhenBarHidden() {
        let frame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        // Fullscreen: visibleFrame reaches the top edge.
        let visible = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        XCTAssertEqual(MenuBarGeometry.menuBarHeight(frame: frame, visibleFrame: visible), 0)
    }

    func testOverlayFrameCoversFullWidthMenuBarStrip() {
        let frame = CGRect(x: 0, y: 0, width: 3440, height: 1440)
        let visible = CGRect(x: 0, y: 0, width: 3440, height: 1410)
        let rect = MenuBarGeometry.overlayFrame(frame: frame, visibleFrame: visible)
        XCTAssertEqual(rect, CGRect(x: 0, y: 1410, width: 3440, height: 30))
    }

    func testOverlayFrameRespectsScreenOrigin() {
        // Non-primary-origin screen (e.g. arranged to the right).
        let frame = CGRect(x: 3440, y: 0, width: 2560, height: 1440)
        let visible = CGRect(x: 3440, y: 0, width: 2560, height: 1416)
        let rect = MenuBarGeometry.overlayFrame(frame: frame, visibleFrame: visible)
        XCTAssertEqual(rect, CGRect(x: 3440, y: 1416, width: 2560, height: 24))
    }
}
