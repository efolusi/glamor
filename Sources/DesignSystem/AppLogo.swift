import SwiftUI

/// The K-caret mark: a K whose stem is the cursor, on a graphite square (design system: Logo).
/// Drawn on a 100-unit square. At 32 and below it uses the small drawing, whose strokes are heavier so
/// they hold up; the stem is thicker and taller than the arms on purpose (optical correction).
struct AppLogo: View {
    var size: CGFloat = K.Tile.t28

    /// In units of the 100-unit square, not points (so scripts/check-sizes.sh leaves them alone).
    private struct Box { let x, y, w, h: CGFloat }

    private struct Drawing {
        let stem: Box             // a capsule
        let arms: [CGPoint]       // top end, joint, bottom end
        let stroke: CGFloat
    }

    private static let large = Drawing(stem: Box(x: 27.5, y: 24, w: 12, h: 52),
                                       arms: [CGPoint(x: 69.5, y: 29.5), CGPoint(x: 50.5, y: 50), CGPoint(x: 69.5, y: 70.5)],
                                       stroke: 10)
    private static let small = Drawing(stem: Box(x: 25, y: 24.5, w: 14, h: 51),
                                       arms: [CGPoint(x: 70.5, y: 31), CGPoint(x: 51.5, y: 50), CGPoint(x: 70.5, y: 69)],
                                       stroke: 12)

    var body: some View {
        let d = size <= K.Tile.t32 ? Self.small : Self.large
        let u = size / 100
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: size * K.Radius.tile, style: .continuous)
                .fill(LinearGradient(colors: [K.Logo.groundTop, K.Logo.groundBottom], startPoint: .top, endPoint: .bottom))
            Path { p in
                p.move(to: CGPoint(x: d.arms[0].x * u, y: d.arms[0].y * u))
                p.addLine(to: CGPoint(x: d.arms[1].x * u, y: d.arms[1].y * u))
                p.addLine(to: CGPoint(x: d.arms[2].x * u, y: d.arms[2].y * u))
            }
            .stroke(K.Logo.ink, style: StrokeStyle(lineWidth: d.stroke * u, lineCap: .round, lineJoin: .round))
            Capsule().fill(K.Logo.cursor)
                .frame(width: d.stem.w * u, height: d.stem.h * u)
                .offset(x: d.stem.x * u, y: d.stem.y * u)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Komando")
    }
}
