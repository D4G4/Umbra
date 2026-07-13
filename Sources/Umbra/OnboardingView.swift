import SwiftUI

/// Three-page welcome/onboarding shown at launch. OLED-black, the app icon as
/// hero, the live dimming demo, then the single control — mirroring the approved
/// design.
struct OnboardingView: View {
    @ObservedObject var settings: AppSettings
    var onFinish: () -> Void

    @State private var page = 0
    @State private var floating = false
    @State private var showWhy = false
    @State private var footerActive = false   // the footer dims until the cursor reaches it — like the app
    private let count = 2

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.black
                pageBody
                    .padding(.horizontal, 56)
                    .padding(.top, 34)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .id(page)
                    .transition(.opacity)
            }
            footer
        }
        .frame(width: 780, height: 560)
        .background(Color.black)
        .preferredColorScheme(.dark)
        .onAppear { floating = true }
        .sheet(isPresented: $showWhy) {
            WhyItMattersView { showWhy = false }
        }
    }

    @ViewBuilder private var pageBody: some View {
        switch page {
        case 0: page1
        default: page2
        }
    }

    // MARK: pages

    private var page1: some View {
        HStack(spacing: 48) {
            Image("UmbraIcon")
                .resizable()
                .frame(width: 172, height: 172)
                .shadow(color: Color(white: 0.85).opacity(0.18), radius: 36)
                .shadow(color: .black.opacity(0.7), radius: 22, y: 14)
                .offset(y: floating ? -6 : 0)
                .animation(.easeInOut(duration: 3.6).repeatForever(autoreverses: true), value: floating)
            VStack(alignment: .leading, spacing: 14) {
                Text("Umbra").font(.system(size: 46, weight: .semibold)).kerning(-1)

                HStack(spacing: 8) {
                    Text("/ˈʌmbrə/").font(.system(size: 14, design: .serif)).italic()
                    Text("·")
                    Text("noun").font(.system(size: 14, design: .serif)).italic()
                }
                .foregroundStyle(.white.opacity(0.42))

                VStack(alignment: .leading, spacing: 8) {
                    Text("The darkest core of a shadow, where the light is fully blocked.")
                        .font(.system(size: 16.5)).foregroundStyle(.white.opacity(0.85)).lineSpacing(3)
                    Text("Which is just what it lays over your static menu bar and Dock — so nothing wears into your OLED.")
                        .font(.system(size: 14.5)).foregroundStyle(.white.opacity(0.5)).lineSpacing(3)
                }
                .frame(maxWidth: 344, alignment: .leading)
                .padding(.top, 2)
            }
            Spacer(minLength: 0)
        }
        .frame(maxHeight: .infinity)
    }

    private var page2: some View {
        VStack(spacing: 0) {
            eyebrow("How it feels")
            Text("It dims. You reach. It clears.").font(.system(size: 26, weight: .semibold)).kerning(-0.3)
                .multilineTextAlignment(.center)
            DesktopDemoView()
                .frame(maxWidth: 560)
                .padding(.top, 22)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }

    private func eyebrow(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10.5, design: .monospaced)).kerning(2.4)
            .foregroundStyle(.white.opacity(0.32))
            .padding(.bottom, 14)
    }

    // MARK: footer

    private var footer: some View {
        HStack {
            Button { showWhy = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                    Text("Why it matters")
                }
                .font(.system(size: 12.5, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, 13).padding(.vertical, 6)
                .background(Capsule().stroke(.white.opacity(0.2)))
            }
            .buttonStyle(.plain)
            Spacer()
            if page > 0 {
                Button("Back") { withAnimation(.easeInOut(duration: 0.35)) { page -= 1 } }
                    .buttonStyle(SecondaryButtonStyle())
            }
            Button(page == count - 1 ? "Get Started" : "Continue") {
                if page == count - 1 { onFinish() }
                else { withAnimation(.easeInOut(duration: 0.35)) { page += 1 } }
            }
            .buttonStyle(PrimaryButtonStyle())
            .keyboardShortcut(.defaultAction)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.black)
        .overlay(Rectangle().fill(.white.opacity(0.07)).frame(height: 1), alignment: .top)
        .opacity(footerActive ? 1 : 0.4)
        .animation(.easeInOut(duration: 0.3), value: footerActive)
        .onHover { footerActive = $0 }
    }

}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 18).padding(.vertical, 8)
            .foregroundStyle(.black)
            .background(Color.white.opacity(configuration.isPressed ? 0.82 : 1),
                        in: RoundedRectangle(cornerRadius: 9, style: .continuous))
    }
}

private struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 16).padding(.vertical, 8)
            .foregroundStyle(.white.opacity(configuration.isPressed ? 0.9 : 0.62))
            .background(Color.white.opacity(configuration.isPressed ? 0.06 : 0),
                        in: RoundedRectangle(cornerRadius: 9, style: .continuous))
    }
}
