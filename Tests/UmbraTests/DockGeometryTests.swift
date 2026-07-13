import XCTest
@testable import Umbra

final class DockGeometryTests: XCTestCase {
    // Full display; menu bar reserves the top 30pt in every case below.
    private let frame = CGRect(x: 0, y: 0, width: 3200, height: 1350)

    func testDetectsLeftDock() {
        // The observed dev-machine layout: 49pt reserved on the left.
        let visible = CGRect(x: 49, y: 0, width: 3151, height: 1320)
        XCTAssertEqual(DockGeometry.dockEdge(frame: frame, visibleFrame: visible), .left)
        let rect = DockGeometry.dockFrame(frame: frame, visibleFrame: visible)
        // Left band, full width 49, height stops below the menu bar (maxY 1320).
        XCTAssertEqual(rect, CGRect(x: 0, y: 0, width: 49, height: 1320))
    }

    func testDetectsBottomDock() {
        let visible = CGRect(x: 0, y: 70, width: 3200, height: 1250)
        XCTAssertEqual(DockGeometry.dockEdge(frame: frame, visibleFrame: visible), .bottom)
        XCTAssertEqual(DockGeometry.dockFrame(frame: frame, visibleFrame: visible),
                       CGRect(x: 0, y: 0, width: 3200, height: 70))
    }

    func testDetectsRightDock() {
        let visible = CGRect(x: 0, y: 0, width: 3140, height: 1320)
        XCTAssertEqual(DockGeometry.dockEdge(frame: frame, visibleFrame: visible), .right)
        XCTAssertEqual(DockGeometry.dockFrame(frame: frame, visibleFrame: visible),
                       CGRect(x: 3140, y: 0, width: 60, height: 1320))
    }

    func testHiddenDockReturnsNil() {
        // Auto-hidden Dock: only the menu bar is reserved (top), no side band.
        let visible = CGRect(x: 0, y: 0, width: 3200, height: 1320)
        XCTAssertNil(DockGeometry.dockEdge(frame: frame, visibleFrame: visible))
        XCTAssertNil(DockGeometry.dockFrame(frame: frame, visibleFrame: visible))
    }
}
