import SwiftUI

/// Explainer sheet: how OLED burn-in happens and why Umbra helps. Opened from
/// the onboarding's "Why it matters" button. Leads with a before/after picture.
struct WhyItMattersView: View {
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Why it matters").font(.system(size: 21, weight: .semibold))
                .padding(.bottom, 14)

            BurnInDiagram().frame(height: 92)
            Text("The same static UI, months later on a solid gray screen — a permanent ghost.")
                .font(.system(size: 11.5)).foregroundStyle(.white.opacity(0.45))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8).padding(.bottom, 14)

            VStack(alignment: .leading, spacing: 12) {
                explainer("circle.grid.3x3.fill", "Pixels light themselves",
                          "Every pixel on an OLED emits its own light — no backlight. Perfect blacks, but each pixel is a tiny lamp that wears.")
                explainer("gauge.with.dots.needle.bottom.50percent", "Light wears them down",
                          "A pixel dims the more it's driven — roughly with brightness × time. Blue sub-pixels fade the fastest.")
                explainer("menubar.rectangle", "Static UI ages unevenly",
                          "Your menu bar and Dock never move, so those pixels run bright all day and age ahead of their neighbours — the ghost.")
            }
            .padding(.bottom, 16)

            HStack(alignment: .top, spacing: 12) {
                Image("MenuBarSphere").resizable().frame(width: 22, height: 22)
                Text("Umbra lays a soft shadow over those static strips, lowering their light so they wear evenly with the rest of the screen.")
                    .font(.system(size: 13)).foregroundStyle(.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))

            HStack {
                Spacer()
                Button("Got it", action: onClose).buttonStyle(WhyButtonStyle())
            }
            .padding(.top, 14)
        }
        .padding(22)
        .frame(width: 520)
        .background(Color.black)
    }

    private func explainer(_ symbol: String, _ title: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 17))
                .foregroundStyle(.white.opacity(0.88))
                .frame(width: 34, height: 34)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 14, weight: .semibold))
                Text(text).font(.system(size: 12.5)).foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// Before/after: a normal desktop in use → the burned-in ghost revealed on a
/// solid gray screen (aged pixels emit less, so they read darker).
private struct BurnInDiagram: View {
    var body: some View {
        HStack(spacing: 16) {
            panel("In daily use", ghost: false)
            Image(systemName: "arrow.right").font(.system(size: 15)).foregroundStyle(.white.opacity(0.3))
            panel("Months later, on gray", ghost: true)
        }
        .frame(maxWidth: .infinity)
    }

    private func panel(_ caption: String, ghost: Bool) -> some View {
        VStack(spacing: 7) {
            ScreenMock(ghost: ghost).aspectRatio(16.0 / 10.0, contentMode: .fit)
            Text(caption).font(.system(size: 10, design: .monospaced)).foregroundStyle(.white.opacity(0.4))
        }
    }
}

private struct ScreenMock: View {
    let ghost: Bool
    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            ZStack(alignment: .top) {
                if ghost {
                    Rectangle().fill(Color(white: 0.46))                    // solid test gray
                } else {
                    Rectangle().fill(LinearGradient(
                        colors: [Color(red: 0.40, green: 0.72, blue: 0.96), Color(red: 0.62, green: 0.40, blue: 0.86)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                }
                // menu bar — bright in use, a darker aged ghost on gray
                Rectangle()
                    .fill(ghost ? Color.black.opacity(0.14) : Color.white.opacity(0.38))
                    .frame(height: h * 0.15)
                // dock
                VStack {
                    Spacer()
                    HStack(spacing: w * 0.025) {
                        ForEach(0..<5, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(ghost ? Color.black.opacity(0.12) : Color.white.opacity(0.55))
                                .frame(width: h * 0.17, height: h * 0.17)
                        }
                    }
                    .padding(.bottom, h * 0.07)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.12)))
        }
    }
}

private struct WhyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 18).padding(.vertical, 8)
            .foregroundStyle(.black)
            .background(Color.white.opacity(configuration.isPressed ? 0.82 : 1),
                        in: RoundedRectangle(cornerRadius: 9, style: .continuous))
    }
}
