import CoreGraphics

/// Whether the cursor is over a strip: `1` when it's inside the menu-bar / Dock
/// rectangle, `0` otherwise. No reach zone and no fixed pixel margin — the strip
/// lightens only while the cursor is literally on top of it. The rectangle is
/// computed live from the screen, so this is resolution-independent and follows
/// Dock resizes automatically.
enum StripProximity {
    static func value(mouse: CGPoint, frame: CGRect) -> Double {
        frame.contains(mouse) ? 1 : 0
    }
}
