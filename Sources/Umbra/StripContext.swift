import CoreGraphics
import Combine

/// Shares the overlay's current screen frame with its `DriftView` so the view
/// can compute cursor proximity to the strip. The controller updates `frame`
/// whenever it repositions the window.
@MainActor
final class StripContext: ObservableObject {
    @Published var frame: CGRect = .zero
}
