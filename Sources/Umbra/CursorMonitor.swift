import AppKit
import Combine

/// Publishes the global cursor location on a steady timer so the overlays can
/// track it even while Umbra is a background agent.
///
/// This deliberately does NOT use SwiftUI `TimelineView`, whose redraws pause
/// when the app isn't active (an agent app almost always is) — which would
/// freeze the hover-lightening. A plain main-runloop timer keeps firing (App Nap
/// is held off by `PowerAssertion`), and a `@Published` change triggers a state
/// redraw regardless of app-active state.
@MainActor
final class CursorMonitor: NSObject, ObservableObject {
    static let shared = CursorMonitor()

    @Published private(set) var location: CGPoint = .zero
    private var timer: Timer?

    override init() {
        super.init()
        location = NSEvent.mouseLocation
    }

    /// Idempotent; safe to call from every overlay.
    func start() {
        guard timer == nil else { return }
        let timer = Timer(timeInterval: 1.0 / 30.0, target: self,
                          selector: #selector(tick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    @objc private func tick() {
        let current = NSEvent.mouseLocation
        if current != location { location = current }   // only publish on real movement
    }
}
