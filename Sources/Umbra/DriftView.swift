import SwiftUI
import AppKit

/// The wash drawn over a strip (menu bar or Dock): a uniform dark scrim that
/// *subtracts* luminance from the static region — the one thing an overlay can
/// do to slow OLED aging (aging ∝ cumulative luminance; adding light, or blue,
/// would make it worse, so we only ever darken, in neutral black).
///
/// Depth follows the cursor: the user-set `dimAlpha` normally, clearing to fully
/// transparent only while the cursor is actually over the strip (no reach zone),
/// so you can read and click the real menu bar / Dock underneath. Cursor updates come from
/// `CursorMonitor` (a timer), not `TimelineView`, so it keeps working while the
/// app is a background agent.
struct DriftView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var context: StripContext
    let strip: Strip
    @ObservedObject private var cursor = CursorMonitor.shared

    var body: some View {
        let proximity = StripProximity.value(mouse: cursor.location, frame: context.frame)
        let alpha = settings.dim(for: strip) * (1 - proximity)
        Rectangle()
            .fill(Color.black.opacity(alpha))
            .animation(.easeOut(duration: 0.12), value: alpha)
            .allowsHitTesting(false)
            .ignoresSafeArea()
    }
}
