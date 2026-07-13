import Foundation

/// Maps the user's dim slider value (black-scrim alpha, `0`…`maxAlpha`) to a
/// percentage and a live "what's this good for" caption. Higher = darker.
struct DimSetting {
    let alpha: Double

    /// Max dimming the slider allows (50% black over the static UI).
    static let maxAlpha: Double = 0.5
    static let range: ClosedRange<Double> = 0...maxAlpha

    var percent: Int { Int((alpha * 100).rounded()) }

    var title: String {
        switch alpha {
        case ..<0.02: return "Off"
        case ..<0.08: return "Barely there"
        case ..<0.20: return "Light"
        case ..<0.35: return "Noticeable"
        default: return "Heavy"
        }
    }

    var detail: String {
        switch alpha {
        case ..<0.02:
            return "No dimming."
        case ..<0.08:
            return "Barely perceptible. Subtle protection for Tandem OLED and low-risk panels."
        case ..<0.20:
            return "Light dimming. Good for most OLED displays in everyday use."
        case ..<0.35:
            return "Noticeable dimming. For regular WOLED / QD-OLED prone to retention."
        default:
            return "Strong dimming — the menu bar and Dock look clearly darker. Maximum protection for static, high-risk UIs."
        }
    }
}
