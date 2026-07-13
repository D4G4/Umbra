import AppKit
import SwiftUI

/// Owns the onboarding window. An `.accessory` app can still show and focus a
/// standard window — we just `activate` to bring it forward, since there's no
/// Dock icon to click. `onClose` fires once when the window is dismissed
/// (Get Started or the red X) so the launch hint can follow.
@MainActor
final class OnboardingWindowController: NSObject, NSWindowDelegate {
    var onClose: (() -> Void)?

    private var window: NSWindow?
    private let settings: AppSettings
    private var didClose = false

    init(settings: AppSettings) {
        self.settings = settings
        super.init()
    }

    /// Show on launch unless the user opted out. Returns whether it showed.
    @discardableResult
    func showIfNeeded() -> Bool {
        guard settings.showWelcomeAtLaunch else { return false }
        show()
        return true
    }

    func show() {
        if window == nil { window = makeWindow() }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
        window?.orderFrontRegardless()
        if let window, let screen = window.screen ?? NSScreen.main {
            let visible = screen.visibleFrame
            let origin = NSPoint(x: (visible.midX - window.frame.width / 2).rounded(),
                                 y: (visible.midY - window.frame.height / 2).rounded())
            window.setFrameOrigin(origin)
        }
    }

    private func makeWindow() -> NSWindow {
        let controller = NSHostingController(
            rootView: OnboardingView(settings: settings) { [weak self] in self?.dismiss() })
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 780, height: 560),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.contentViewController = controller
        window.setContentSize(NSSize(width: 780, height: 560))
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.backgroundColor = .black
        window.title = "Welcome to Umbra"
        window.level = .floating
        window.isReleasedWhenClosed = false
        window.delegate = self
        return window
    }

    private func dismiss() {
        window?.orderOut(nil)   // Get Started — orderOut doesn't post willClose
        handleClose()
    }

    func windowWillClose(_ notification: Notification) { handleClose() }   // red X

    private func handleClose() {
        guard !didClose else { return }
        didClose = true
        onClose?()
    }
}
