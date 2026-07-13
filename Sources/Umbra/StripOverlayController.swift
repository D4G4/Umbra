import AppKit
import SwiftUI
import Combine

/// A transparent, click-through overlay window pinned over a screen "strip"
/// (the menu bar or the Dock). Level is `statusWindow + 1` (26) so it renders
/// above the menu bar's status items (level 25) and the Dock (level 20), while
/// staying below dropdown menus (level 101) — so native menus stay clickable.
///
/// The window deliberately does NOT use `.canJoinAllSpaces`: it lives on the
/// desktop Space where it's created and therefore never appears on a fullscreen
/// app's Space — that's how it stays out of fullscreen, with no flaky detection.
/// (Trade-off: a second Mission Control desktop won't be covered.)
///
/// Visibility is level-triggered: `update()` recomputes the desired state and is
/// called on the relevant notifications *and* on a 1s reconcile timer, so a
/// missed event can't leave it stuck. Every transition is logged to file + os_log.
@MainActor
final class StripOverlayController: NSObject {
    private let label: String
    private let strip: Strip
    private var window: NSWindow?
    private let settings: AppSettings
    private let isEnabled: () -> Bool
    private let frameProvider: (NSScreen) -> CGRect?
    private let context = StripContext()
    private var cancellables = Set<AnyCancellable>()
    private var reconcileTimer: Timer?
    private var lastState = ""

    init(label: String,
         strip: Strip,
         settings: AppSettings,
         enabledPublisher: AnyPublisher<Bool, Never>,
         isEnabled: @escaping () -> Bool,
         frameProvider: @escaping (NSScreen) -> CGRect?) {
        self.label = label
        self.strip = strip
        self.settings = settings
        self.isEnabled = isEnabled
        self.frameProvider = frameProvider
        super.init()

        CursorMonitor.shared.start()

        enabledPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.update() }
            .store(in: &cancellables)

        NotificationCenter.default.addObserver(
            self, selector: #selector(update),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(update),
            name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)

        let timer = Timer(timeInterval: 1.0, target: self,
                          selector: #selector(update), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        reconcileTimer = timer

        Log.overlay("[\(label)] controller init")
        update()
    }
    // No deinit: app-lifetime object (retained by the reconcile timer and
    // AppDelegate); process teardown releases everything.

    @objc private func update() {
        guard isEnabled() else { hide("disabled"); return }
        guard let screen = primaryScreen else { hide("no-screen"); return }
        guard let rect = frameProvider(screen), rect.width > 0, rect.height > 0 else {
            hide("no-band"); return
        }

        if window == nil { window = makeWindow() }
        if window?.frame != rect {
            window?.setFrame(rect, display: true)
            context.frame = rect
        }
        if window?.isVisible != true { window?.orderFrontRegardless() }

        if lastState != "shown" {
            Log.overlay("[\(label)] SHOW \(NSStringFromRect(rect))")
            lastState = "shown"
        }
    }

    private func hide(_ reason: String) {
        window?.orderOut(nil)
        if lastState != reason {
            Log.overlay("[\(label)] HIDE (\(reason))")
            lastState = reason
        }
    }

    private var primaryScreen: NSScreen? {
        NSScreen.screens.first(where: { $0.frame.origin == .zero }) ?? NSScreen.main
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(contentRect: .zero, styleMask: .borderless,
                              backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.statusWindow)) + 1)
        window.collectionBehavior = [.ignoresCycle]   // NOT canJoinAllSpaces — see class note
        window.isReleasedWhenClosed = false

        let host = NSHostingView(rootView: DriftView(settings: settings, context: context, strip: strip))
        host.autoresizingMask = [.width, .height]
        window.contentView = host
        return window
    }
}
