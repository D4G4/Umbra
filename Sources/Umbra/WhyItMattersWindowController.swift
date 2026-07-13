import AppKit
import SwiftUI

/// Shows the "Why it matters" OLED explainer as a standalone window — used from
/// the menu panel's About tab (the onboarding shows it as a sheet).
@MainActor
final class WhyItMattersWindowController {
    static let shared = WhyItMattersWindowController()
    private var window: NSWindow?

    func show() {
        if let window {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }
        let controller = NSHostingController(rootView: WhyItMattersView { [weak self] in self?.dismiss() })
        let window = NSWindow(contentViewController: controller)
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.backgroundColor = .black
        window.title = "Why it matters"
        window.isReleasedWhenClosed = false
        window.level = .floating
        NSApp.activate(ignoringOtherApps: true)
        window.center()
        window.makeKeyAndOrderFront(nil)
        self.window = window
    }

    private func dismiss() { window?.orderOut(nil) }
}
