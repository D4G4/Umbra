import Foundation

/// Prevents App Nap from throttling Umbra's timers/animation while a washer
/// is active. Uses `.userInitiatedAllowingIdleSystemSleep` so the Mac can still
/// sleep normally on idle — we only want to keep running while the user is at
/// the machine (a sleeping display can't retain an image).
@MainActor
final class PowerAssertion {
    private var token: NSObjectProtocol?
    private let reason: String

    init(reason: String) { self.reason = reason }

    func activate() {
        guard token == nil else { return }
        token = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiatedAllowingIdleSystemSleep], reason: reason)
    }

    func deactivate() {
        if let token { ProcessInfo.processInfo.endActivity(token) }
        token = nil
    }
}
