import SwiftUI

/// The dropdown control panel shown from the menu-bar item. Two tabs:
/// Controls (the live settings) and About (identity, help, updates).
struct ControlPanelView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject private var updater = UmbraUpdater.shared
    @State private var tab: Tab = .controls

    private enum Tab: String, CaseIterable, Identifiable {
        case controls = "Controls", about = "About"
        var id: String { rawValue }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image("MenuBarSphere").resizable().frame(width: 18, height: 18)
                Text("Umbra").font(.headline)
            }

            Picker("", selection: $tab) {
                ForEach(Tab.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            if tab == .controls { controlsTab } else { aboutTab }

            Divider()

            HStack {
                Button("Open Log") {
                    NSWorkspace.shared.activateFileViewerSelecting([FileLog.shared.fileURL])
                }
                Spacer()
                Button("Quit Umbra") { NSApplication.shared.terminate(nil) }
                    .keyboardShortcut("q")
            }
        }
        .padding(16)
        .frame(width: 300)
    }

    // MARK: Controls

    @ViewBuilder private var controlsTab: some View {
        Toggle("Menu Bar", isOn: $settings.overlayEnabled)
        Toggle("Dock", isOn: $settings.dockEnabled)

        if settings.separateDimming {
            dimRow("Menu Bar dim", value: $settings.dimAlpha)
            dimRow("Dock dim", value: $settings.dockDimAlpha)
        } else {
            dimRow("Dimming", value: $settings.dimAlpha, showDetail: true)
        }

        Toggle("Separate menu bar & Dock", isOn: separateDimmingBinding)
            .font(.caption).foregroundStyle(.secondary)

        Toggle("Launch at Login", isOn: launchAtLoginBinding)
        Toggle("Show welcome at launch", isOn: $settings.showWelcomeAtLaunch)
    }

    // MARK: About

    @ViewBuilder private var aboutTab: some View {
        VStack(spacing: 12) {
            Image("UmbraIcon").resizable().frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .black.opacity(0.4), radius: 6, y: 3)

            VStack(spacing: 2) {
                Text("Umbra Guard").font(.headline)
                Text("Version \(appVersion)").font(.caption).foregroundStyle(.secondary)
            }

            Text("A soft shadow for your menu bar and Dock — so a static UI never wears into your OLED.")
                .font(.caption).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 6) {
                Button {
                    WhyItMattersWindowController.shared.show()
                } label: { aboutButtonLabel("Why it matters", "info.circle") }
                .buttonStyle(.bordered)

                Button {
                    updater.checkForUpdates()
                } label: { aboutButtonLabel("Check for Updates…", "arrow.triangle.2.circlepath") }
                .buttonStyle(.bordered)
                .disabled(!updater.canCheckForUpdates)
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }

    private func aboutButtonLabel(_ title: String, _ symbol: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
            Text(title)
        }
        .frame(maxWidth: .infinity)
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return b.isEmpty ? v : "\(v) (\(b))"
    }

    // MARK: helpers

    private func dimRow(_ label: String, value: Binding<Double>, showDetail: Bool = false) -> some View {
        let dim = DimSetting(alpha: value.wrappedValue)
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                Spacer()
                Text("\(dim.percent)% · \(dim.title)")
                    .foregroundStyle(.secondary).monospacedDigit()
            }
            Slider(value: value, in: AppSettings.dimRange)
            if showDetail {
                Text(dim.detail)
                    .font(.caption).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var separateDimmingBinding: Binding<Bool> {
        Binding(get: { settings.separateDimming },
                set: { settings.setSeparateDimming($0) })
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(get: { settings.launchAtLogin },
                set: { settings.updateLaunchAtLogin($0) })
    }
}
