import AppKit
import Combine
import SwiftUI
import MenuBarKit

/// Wires the AppKit-side overlays together and keeps a power assertion alive
/// while any protection is on. Umbra is a pure `.accessory` agent — no Dock tile,
/// no Cmd-Tab entry, ever.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = AppSettings.shared
    private var menuBarOverlay: StripOverlayController?
    private var dockOverlay: StripOverlayController?
    private var onboarding: OnboardingWindowController?
    private let power = PowerAssertion(reason: "Umbra keeping pixels moving")
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        Log.app("launched")
        NSApp.appearance = NSAppearance(named: .darkAqua)   // Umbra is always dark, like its icon
        UmbraUpdater.shared.checkInBackgroundAfterLaunch()  // Sparkle: start updater + background check
        let settings = self.settings

        menuBarOverlay = StripOverlayController(
            label: "menu-bar",
            strip: .menuBar,
            settings: settings,
            enabledPublisher: settings.$overlayEnabled.eraseToAnyPublisher(),
            isEnabled: { settings.overlayEnabled },
            frameProvider: { MenuBarGeometry.overlayFrame(frame: $0.frame, visibleFrame: $0.visibleFrame) })

        dockOverlay = StripOverlayController(
            label: "dock",
            strip: .dock,
            settings: settings,
            enabledPublisher: settings.$dockEnabled.eraseToAnyPublisher(),
            isEnabled: { settings.dockEnabled },
            frameProvider: { DockGeometry.dockFrame(frame: $0.frame, visibleFrame: $0.visibleFrame) })

        let onboarding = OnboardingWindowController(settings: settings)
        onboarding.onClose = { [weak self] in self?.showLaunchHint() }
        let shownOnboarding = onboarding.showIfNeeded()
        self.onboarding = onboarding
        if !shownOnboarding { showLaunchHint() }   // no onboarding → hint on launch

        // Keep App Nap at bay whenever any protection is on.
        Publishers.CombineLatest(settings.$overlayEnabled, settings.$dockEnabled)
            .receive(on: RunLoop.main)
            .sink { [weak self] overlayOn, dockOn in
                if overlayOn || dockOn { self?.power.activate() } else { self?.power.deactivate() }
            }
            .store(in: &cancellables)
    }

    private func showLaunchHint() {
        Log.app("showing launch hint banner")
        let settings = self.settings
        let icon = NSImage(named: "UmbraIcon") ?? NSApp.applicationIconImage ?? NSImage()
        let config = MenuBarHintConfig(
            appName: "Umbra",
            icon: icon,
            lookForText: "Look for the sphere in your menu bar.",
            theme: .dark,
            fallback: .init(label: "Open Umbra controls", systemImage: "slider.horizontal.3") {
                ControlsWindowController.shared.show(settings: settings)
            })
        MenuBarHint.showLaunchBanner(config)
    }
}
