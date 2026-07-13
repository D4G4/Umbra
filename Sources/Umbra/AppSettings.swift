import Foundation
import Combine

/// Which static strip an overlay covers.
enum Strip { case menuBar, dock }

/// Single source of truth for user preferences, persisted to `UserDefaults`.
/// Both the SwiftUI control panel and the AppKit overlay controllers observe it.
@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    /// Dimming amount = black-scrim alpha, `0`…`DimSetting.maxAlpha`.
    static let dimRange = DimSetting.range

    @Published var overlayEnabled: Bool {
        didSet { defaults.set(overlayEnabled, forKey: Keys.overlayEnabled) }
    }
    @Published var dockEnabled: Bool {
        didSet { defaults.set(dockEnabled, forKey: Keys.dockEnabled) }
    }
    /// Menu-bar dim, and the shared dim when `separateDimming` is off.
    @Published var dimAlpha: Double {
        didSet {
            let clamped = Self.clamp(dimAlpha, to: Self.dimRange)
            if clamped != dimAlpha { dimAlpha = clamped; return }
            defaults.set(dimAlpha, forKey: Keys.dimAlpha)
        }
    }
    /// Dock dim, used only when `separateDimming` is on.
    @Published var dockDimAlpha: Double {
        didSet {
            let clamped = Self.clamp(dockDimAlpha, to: Self.dimRange)
            if clamped != dockDimAlpha { dockDimAlpha = clamped; return }
            defaults.set(dockDimAlpha, forKey: Keys.dockDimAlpha)
        }
    }
    /// When on, the menu bar and Dock have independent dim sliders.
    @Published var separateDimming: Bool {
        didSet { defaults.set(separateDimming, forKey: Keys.separateDimming) }
    }
    @Published var showWelcomeAtLaunch: Bool {
        didSet { defaults.set(showWelcomeAtLaunch, forKey: Keys.showWelcomeAtLaunch) }
    }
    /// Reflects the real `SMAppService` state; mutate via `updateLaunchAtLogin`.
    @Published private(set) var launchAtLogin: Bool

    private let defaults: UserDefaults

    enum Keys {
        static let overlayEnabled = "overlayEnabled"
        static let dockEnabled = "dockEnabled"
        static let dimAlpha = "dimAlpha"
        static let dockDimAlpha = "dockDimAlpha"
        static let separateDimming = "separateDimming"
        static let showWelcomeAtLaunch = "showWelcomeAtLaunch"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Keys.overlayEnabled: true,
            Keys.dockEnabled: true,
            Keys.dimAlpha: 0.22,          // "Noticeable" — a regular-OLED default
            Keys.dockDimAlpha: 0.22,
            Keys.separateDimming: false,
            Keys.showWelcomeAtLaunch: true,
        ])
        self.overlayEnabled = defaults.bool(forKey: Keys.overlayEnabled)
        self.dockEnabled = defaults.bool(forKey: Keys.dockEnabled)
        self.dimAlpha = Self.clamp(defaults.double(forKey: Keys.dimAlpha), to: Self.dimRange)
        self.dockDimAlpha = Self.clamp(defaults.double(forKey: Keys.dockDimAlpha), to: Self.dimRange)
        self.separateDimming = defaults.bool(forKey: Keys.separateDimming)
        self.showWelcomeAtLaunch = defaults.bool(forKey: Keys.showWelcomeAtLaunch)
        self.launchAtLogin = LaunchAtLogin.isEnabled
    }

    /// The dim alpha for a given strip. The Dock follows the shared value unless
    /// the user has split them.
    func dim(for strip: Strip) -> Double {
        switch strip {
        case .menuBar: return dimAlpha
        case .dock: return separateDimming ? dockDimAlpha : dimAlpha
        }
    }

    /// Toggle split dimming; when turning it on, seed the Dock value from the
    /// shared one so the two start matched.
    func setSeparateDimming(_ on: Bool) {
        if on && !separateDimming { dockDimAlpha = dimAlpha }
        separateDimming = on
    }

    /// Toggle launch-at-login, then resync to the OS's actual state so the UI
    /// never shows a value the system didn't accept.
    func updateLaunchAtLogin(_ enabled: Bool) {
        try? LaunchAtLogin.setEnabled(enabled)
        launchAtLogin = LaunchAtLogin.isEnabled
    }

    static func clamp(_ value: Double, to range: ClosedRange<Double>) -> Double {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
