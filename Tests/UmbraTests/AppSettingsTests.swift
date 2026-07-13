import XCTest
@testable import Umbra

@MainActor
final class AppSettingsTests: XCTestCase {
    private func makeDefaults() -> UserDefaults {
        let suite = "UmbraTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    func testDefaults() {
        let settings = AppSettings(defaults: makeDefaults())
        XCTAssertTrue(settings.overlayEnabled)
        XCTAssertTrue(settings.dockEnabled)
        XCTAssertEqual(settings.dimAlpha, 0.22, accuracy: 1e-9)
        XCTAssertTrue(settings.showWelcomeAtLaunch)
    }

    func testDimAlphaClampsToRange() {
        let settings = AppSettings(defaults: makeDefaults())
        settings.dimAlpha = 5
        XCTAssertEqual(settings.dimAlpha, AppSettings.dimRange.upperBound, accuracy: 1e-9)
        settings.dimAlpha = -1
        XCTAssertEqual(settings.dimAlpha, AppSettings.dimRange.lowerBound, accuracy: 1e-9)
    }

    func testPersistenceRoundTrips() {
        let defaults = makeDefaults()
        let first = AppSettings(defaults: defaults)
        first.overlayEnabled = false
        first.dockEnabled = true
        first.dimAlpha = 0.31
        first.showWelcomeAtLaunch = false

        let second = AppSettings(defaults: defaults)
        XCTAssertFalse(second.overlayEnabled)
        XCTAssertTrue(second.dockEnabled)
        XCTAssertEqual(second.dimAlpha, 0.31, accuracy: 1e-9)
        XCTAssertFalse(second.showWelcomeAtLaunch)
    }
}
