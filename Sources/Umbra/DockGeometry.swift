import CoreGraphics

/// Pure geometry for locating the Dock strip from a screen's `frame` vs
/// `visibleFrame`. The Dock reserves a band on one edge (bottom/left/right);
/// the menu bar reserves the top, which we ignore here.
///
/// Returns `nil` when no Dock band is reserved — i.e. the Dock is auto-hidden or
/// on another display — so the overlay hides rather than washing empty space.
enum DockGeometry {
    enum Edge { case bottom, left, right }

    static func dockEdge(frame: CGRect, visibleFrame: CGRect) -> Edge? {
        let bottom = visibleFrame.minY - frame.minY
        let left = visibleFrame.minX - frame.minX
        let right = frame.maxX - visibleFrame.maxX
        let maxInset = max(bottom, max(left, right))
        guard maxInset > 0.5 else { return nil }
        if maxInset == bottom { return .bottom }
        if maxInset == left { return .left }
        return .right
    }

    /// The rect (screen coordinates) covering the reserved Dock band. Side Docks
    /// stop below the menu bar so the two overlays don't double up in the corner.
    static func dockFrame(frame: CGRect, visibleFrame: CGRect) -> CGRect? {
        guard let edge = dockEdge(frame: frame, visibleFrame: visibleFrame) else { return nil }
        switch edge {
        case .bottom:
            let height = visibleFrame.minY - frame.minY
            return CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: height)
        case .left:
            let width = visibleFrame.minX - frame.minX
            let height = visibleFrame.maxY - frame.minY
            return CGRect(x: frame.minX, y: frame.minY, width: width, height: height)
        case .right:
            let width = frame.maxX - visibleFrame.maxX
            let height = visibleFrame.maxY - frame.minY
            return CGRect(x: frame.maxX - width, y: frame.minY, width: width, height: height)
        }
    }
}
