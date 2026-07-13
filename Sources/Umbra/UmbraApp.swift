import SwiftUI

@main
struct UmbraApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Umbra", image: "MenuBarSphere") {
            ControlPanelView(settings: .shared)
        }
        .menuBarExtraStyle(.window)
    }
}
