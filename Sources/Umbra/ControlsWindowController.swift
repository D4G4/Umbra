import AppKit
import SwiftUI

/// Guaranteed entry point to Umbra's controls, used as the "can't find it"
/// fallback — so the app stays adjustable even if its menu-bar icon is hidden.
@MainActor
final class ControlsWindowController {
    static let shared = ControlsWindowController()
    private var window: NSWindow?

    func show(settings: AppSettings) {
        if let window {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }
        let controller = NSHostingController(rootView: ControlPanelView(settings: settings))
        let window = NSWindow(contentViewController: controller)
        window.styleMask = [.titled, .closable]
        window.title = "Umbra"
        window.isReleasedWhenClosed = false
        window.level = .floating
        NSApp.activate(ignoringOtherApps: true)
        window.center()
        window.makeKeyAndOrderFront(nil)
        self.window = window
    }
}
