import SwiftUI

/// Drives the demo loop. Held by `@StateObject` so it survives view re-renders
/// (a plain `Timer.publish` property gets recreated every render and never
/// fires). Target/selector timer on the main runloop.
@MainActor
final class DemoClock: NSObject, ObservableObject {
    @Published var phase: Double = 0
    private var timer: Timer?
    private static let period: Double = 10

    func start() {
        guard timer == nil else { return }
        let timer = Timer(timeInterval: 1.0 / 30.0, target: self,
                          selector: #selector(tick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() { timer?.invalidate(); timer = nil }

    @objc private func tick() {
        phase = (phase + (1.0 / 30.0) / Self.period).truncatingRemainder(dividingBy: 1.0)
    }
}

private struct CursorShape: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height
        var p = Path()
        p.move(to: CGPoint(x: 0.06 * w, y: 0.02 * h))
        p.addLine(to: CGPoint(x: 0.06 * w, y: 0.80 * h))
        p.addLine(to: CGPoint(x: 0.29 * w, y: 0.60 * h))
        p.addLine(to: CGPoint(x: 0.44 * w, y: 0.95 * h))
        p.addLine(to: CGPoint(x: 0.58 * w, y: 0.88 * h))
        p.addLine(to: CGPoint(x: 0.43 * w, y: 0.55 * h))
        p.addLine(to: CGPoint(x: 0.72 * w, y: 0.55 * h))
        p.closeSubpath()
        return p
    }
}

/// A refined, floating macOS "display" that loops Umbra's behaviour: the cursor
/// rises to the menu bar (which clears while it's there), drops to the Dock
/// (which clears), and each re-dims once the cursor leaves. Presented as a
/// framed screen with a muted, premium wallpaper to match the app's aesthetic.
struct DesktopDemoView: View {
    @StateObject private var clock = DemoClock()

    // Monochrome glass Dock tiles — light grays with a gloss, no colour.
    private let tiles: [LinearGradient] = [
        .init(colors: [Color(white: 0.74), Color(white: 0.52)], startPoint: .top, endPoint: .bottom),
        .init(colors: [Color(white: 0.68), Color(white: 0.46)], startPoint: .top, endPoint: .bottom),
        .init(colors: [Color(white: 0.72), Color(white: 0.50)], startPoint: .top, endPoint: .bottom),
        .init(colors: [Color(white: 0.66), Color(white: 0.44)], startPoint: .top, endPoint: .bottom),
        .init(colors: [Color(white: 0.70), Color(white: 0.48)], startPoint: .top, endPoint: .bottom),
    ]
    // Dark desktop (like dark mode on an OLED) so it sits with the app's theme;
    // the menu bar / Dock are the lighter elements the dim then darkens.
    private let wallpaper = LinearGradient(
        colors: [Color(white: 0.17), Color(white: 0.06)],
        startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        let p = clock.phase
        screen(p: p)
            .aspectRatio(16.0 / 10.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(  // faint top glare for a glassy screen feel
                LinearGradient(colors: [.white.opacity(0.10), .clear], startPoint: .top, endPoint: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .allowsHitTesting(false))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(.white.opacity(0.12), lineWidth: 1))
            .padding(7)
            .background(  // dark bezel
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient(colors: [Color(white: 0.14), Color(white: 0.06)], startPoint: .top, endPoint: .bottom))
                    .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(.white.opacity(0.08), lineWidth: 1)))
            .shadow(color: .black.opacity(0.55), radius: 30, y: 16)
            .onAppear { clock.start() }
            .onDisappear { clock.stop() }
    }

    private func screen(p: Double) -> some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let barH = max(20, h * 0.095)
            let unit = h * 0.15
            ZStack(alignment: .topLeading) {
                Rectangle().fill(wallpaper)
                // soft vignette for depth
                RadialGradient(colors: [.clear, .black.opacity(0.18)], center: .center, startRadius: h * 0.25, endRadius: h * 0.85)
                    .allowsHitTesting(false)

                menuBar(width: w, height: barH, scrim: menuScrim(p))

                dock(unit: unit, scrim: dockScrim(p))
                    .position(x: w / 2, y: h - unit * 0.95)

                CursorShape()
                    .fill(.white)
                    .overlay(CursorShape().stroke(.black.opacity(0.8), lineWidth: 0.75))
                    .frame(width: h * 0.075, height: h * 0.075)
                    .shadow(color: .black.opacity(0.4), radius: 1.5, y: 1)
                    .position(x: w * 0.50, y: cursorY(p, h: h))
            }
        }
    }

    private func menuBar(width: CGFloat, height: CGFloat, scrim: Double) -> some View {
        HStack(spacing: height * 0.5) {
            Circle().fill(RadialGradient(colors: [Color(white: 0.95), Color(white: 0.5), Color(white: 0.12)],
                                         center: .init(x: 0.34, y: 0.30), startRadius: 0, endRadius: height * 0.22))
                .frame(width: height * 0.40, height: height * 0.40)
            Text("Umbra").fontWeight(.semibold)
            Text("File").opacity(0.85); Text("Edit").opacity(0.85); Text("View").opacity(0.85)
            Spacer()
            Image(systemName: "wifi")
            Image(systemName: "battery.75")
            Text("9:41").monospacedDigit()
        }
        .font(.system(size: height * 0.38))
        .foregroundStyle(.white)
        .padding(.horizontal, height * 0.7)
        .frame(width: width, height: height)
        .background(.white.opacity(0.16))
        .overlay(Rectangle().fill(.white.opacity(0.14)).frame(height: 1), alignment: .bottom)
        .overlay(Rectangle().fill(.black).opacity(scrim))
    }

    private func dock(unit: CGFloat, scrim: Double) -> some View {
        HStack(spacing: unit * 0.26) {
            ForEach(0..<tiles.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: unit * 0.26, style: .continuous)
                    .fill(tiles[i])
                    .overlay(  // top gloss
                        LinearGradient(colors: [.white.opacity(0.4), .clear], startPoint: .top, endPoint: .center)
                            .clipShape(RoundedRectangle(cornerRadius: unit * 0.26, style: .continuous)))
                    .overlay(RoundedRectangle(cornerRadius: unit * 0.26, style: .continuous).strokeBorder(.white.opacity(0.18), lineWidth: 0.5))
                    .frame(width: unit, height: unit)
                    .shadow(color: .black.opacity(0.28), radius: 2.5, y: 1.5)
            }
        }
        .padding(unit * 0.3)
        .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: unit * 0.5, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: unit * 0.5, style: .continuous).strokeBorder(.white.opacity(0.14), lineWidth: 0.5))
        .overlay(RoundedRectangle(cornerRadius: unit * 0.5, style: .continuous).fill(.black).opacity(scrim))
    }
}

// MARK: - keyframe timeline (0…1): rest → menu bar (clears) → Dock (clears) → rest

private func lp(_ a: Double, _ b: Double, _ t: Double) -> Double { a + (b - a) * min(max(t, 0), 1) }

private let dimMax = 0.55

private func menuScrim(_ p: Double) -> Double {
    switch p {
    case ..<0.08: return lp(0, dimMax, p / 0.08)
    case ..<0.18: return dimMax
    case ..<0.22: return lp(dimMax, 0, (p - 0.18) / 0.04)
    case ..<0.32: return 0
    case ..<0.36: return lp(0, dimMax, (p - 0.32) / 0.04)
    default: return dimMax
    }
}

private func dockScrim(_ p: Double) -> Double {
    switch p {
    case ..<0.08: return lp(0, dimMax, p / 0.08)
    case ..<0.44: return dimMax
    case ..<0.48: return lp(dimMax, 0, (p - 0.44) / 0.04)
    case ..<0.60: return 0
    case ..<0.64: return lp(0, dimMax, (p - 0.60) / 0.04)
    default: return dimMax
    }
}

private func cursorY(_ p: Double, h: CGFloat) -> CGFloat {
    let rest = Double(h) * 0.45, menu = Double(h) * 0.05, dock = Double(h) * 0.86
    let y: Double
    switch p {
    case ..<0.10: y = rest
    case ..<0.22: y = lp(rest, menu, (p - 0.10) / 0.12)
    case ..<0.32: y = menu
    case ..<0.48: y = lp(menu, dock, (p - 0.32) / 0.16)
    case ..<0.60: y = dock
    case ..<0.72: y = lp(dock, rest, (p - 0.60) / 0.12)
    default: y = rest
    }
    return CGFloat(y)
}
