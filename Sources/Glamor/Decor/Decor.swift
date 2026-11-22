import SwiftUI

/// A decorative backdrop for a hero or a section: gradient mesh, grain, grid or dots, drawn from the accent
/// and text colours so dark mode and a rebrand reach it. It is hidden from VoiceOver, never animated (so
/// Reduce Motion has nothing to stop) and gone under Increase Contrast, where a pattern only adds noise.
/// Put it behind the content with `.background { Decor(.mesh, fade: true) }`. Body text in `G.text` or
/// `G.text2` stays readable over every pattern; do not put `G.text3` or small light text on it.
/// Use one pattern per section, and only where the page gains something from it.
public struct Decor: View {
    private let pattern: DecorPattern
    private let fade: Bool
    @Environment(\.colorSchemeContrast) private var contrast

    /// - Parameters:
    ///   - pattern: which backdrop to draw.
    ///   - fade: fades the pattern out toward the bottom edge.
    public init(_ pattern: DecorPattern = .mesh, fade: Bool = false) {
        self.pattern = pattern
        self.fade = fade
    }

    public var body: some View {
        if contrast == .standard {
            Canvas { context, size in
                Decor.draw(pattern, in: &context, size: size)
            }
            .mask {
                if fade {
                    LinearGradient(stops: [.init(color: .black, location: 0.55), .init(color: .clear, location: 1)],
                                   startPoint: .top, endPoint: .bottom)
                } else {
                    Rectangle()
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }

    private static func draw(_ pattern: DecorPattern, in context: inout GraphicsContext, size: CGSize) {
        let top = pattern.strongest
        switch pattern {
        case .mesh:
            blob(&context, size, at: CGPoint(x: 0.15, y: 0.1), radius: 0.6, color: Color(GlamorTokens.Color.accentSubtle), strength: top)
            blob(&context, size, at: CGPoint(x: 0.85, y: 0.2), radius: 0.55, color: Color(GlamorTokens.Color.accentSubtle), strength: top * 0.7)
            blob(&context, size, at: CGPoint(x: 0.5, y: 1), radius: 0.7, color: G.accent, strength: 0.06)
        case .grid:
            let step = 32.0
            var path = Path()
            for x in stride(from: 0, through: size.width, by: step) { path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: size.height)) }
            for y in stride(from: 0, through: size.height, by: step) { path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: size.width, y: y)) }
            context.stroke(path, with: .color(G.text3.opacity(top)), lineWidth: 1)
        case .dots:
            let step = 20.0
            for x in stride(from: step / 2, to: size.width, by: step) {
                for y in stride(from: step / 2, to: size.height, by: step) {
                    context.fill(Path(ellipseIn: CGRect(x: x - 1, y: y - 1, width: 2, height: 2)), with: .color(G.text3.opacity(top)))
                }
            }
        case .noise:
            // Three offset lattices of tiny dots, as Meridian's grain: no random numbers, so it never shimmers.
            for (step, offset, share) in [(7.0, CGPoint.zero, 1.0), (11.0, CGPoint(x: 3, y: 5), 0.8), (13.0, CGPoint(x: 6, y: 2), 0.65)] {
                for x in stride(from: offset.x, to: size.width, by: step) {
                    for y in stride(from: offset.y, to: size.height, by: step) {
                        context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)), with: .color(G.text3.opacity(top * share)))
                    }
                }
            }
        }
    }

    private static func blob(_ context: inout GraphicsContext, _ size: CGSize, at unit: CGPoint, radius: Double, color: Color, strength: Double) {
        let center = CGPoint(x: unit.x * size.width, y: unit.y * size.height)
        let r = radius * max(size.width, size.height)
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .radialGradient(Gradient(colors: [color.opacity(strength), color.opacity(0)]), center: center, startRadius: 0, endRadius: r)
        )
    }
}
