import CoreGraphics

/// Pure geometry helpers for placing the overlay window over the menu bar.
///
/// macOS screen coordinates are bottom-left origin, y-up. `frame` is the full
/// display; `visibleFrame` excludes the menu bar (top) and Dock. So the menu bar
/// strip runs from `visibleFrame.maxY` up to `frame.maxY`.
enum MenuBarGeometry {
    /// Height of the menu bar for a screen. `0` when the bar is hidden
    /// (e.g. an app is in fullscreen on that screen).
    static func menuBarHeight(frame: CGRect, visibleFrame: CGRect) -> CGFloat {
        max(0, frame.maxY - visibleFrame.maxY)
    }

    /// Overlay rect (screen coordinates) covering the full-width menu bar strip.
    static func overlayFrame(frame: CGRect, visibleFrame: CGRect) -> CGRect {
        let height = menuBarHeight(frame: frame, visibleFrame: visibleFrame)
        return CGRect(x: frame.minX, y: frame.maxY - height, width: frame.width, height: height)
    }
}
