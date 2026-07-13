import Foundation
import Sparkle

/// Thin wrapper around Sparkle's standard updater so the rest of the app can
/// call `.checkForUpdates()` without importing Sparkle everywhere.
///
/// Configured via Info.plist (see project.yml):
///   - SUFeedURL              → the appcast.xml URL you host
///   - SUPublicEDKey          → public half of your EdDSA signing pair
///   - SUEnableAutomaticChecks→ background daily check
///   - SUScheduledCheckInterval → 86400 (24h)
///
/// Instantiated once at launch (AppDelegate). Owns the periodic background
/// check, the user-driven "Check for Updates…" action, and Sparkle's standard
/// notice → download → install → relaunch UI.
@MainActor
final class UmbraUpdater: NSObject, ObservableObject {
    static let shared = UmbraUpdater()

    private let controller: SPUStandardUpdaterController

    /// Mirrors Sparkle's `canCheckForUpdates` so the menu button can disable
    /// itself while a check is already running.
    @Published private(set) var canCheckForUpdates = false

    private override init() {
        controller = SPUStandardUpdaterController(
            startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        super.init()
        controller.updater.publisher(for: \.canCheckForUpdates)
            .receive(on: RunLoop.main)
            .assign(to: &$canCheckForUpdates)
    }

    /// User-initiated check — shows progress, then a dialog whether or not an
    /// update is available.
    func checkForUpdates() { controller.checkForUpdates(nil) }

    /// Silent background check shortly after launch (a relaunched menu-bar app
    /// should feel like it checks "now", not on the next 24h tick). Surfaces the
    /// standard dialog only if an update is found.
    func checkInBackgroundAfterLaunch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) { [weak self] in
            self?.controller.updater.checkForUpdatesInBackground()
        }
    }
}
