import ServiceManagement

/// Thin wrapper over `SMAppService` for launch-at-login (macOS 13+).
/// Best-effort: registration can throw when the app runs unsigned or from an
/// unusual location during development; callers resync to `isEnabled`.
enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func setEnabled(_ enabled: Bool) throws {
        switch (enabled, SMAppService.mainApp.status) {
        case (true, let s) where s != .enabled:
            try SMAppService.mainApp.register()
        case (false, .enabled):
            try SMAppService.mainApp.unregister()
        default:
            break
        }
    }
}
