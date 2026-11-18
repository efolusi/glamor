import SwiftUI
import UIKit

/// The K-caret mark, drawn like the Mac's AppLogo (small drawing).
struct AppLogo: View {
    var size: CGFloat = 28
    var body: some View {
        let u = size / 100
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
                .fill(LinearGradient(colors: [MK.Logo.groundTop, MK.Logo.groundBottom],
                                     startPoint: .top, endPoint: .bottom))
            Path { p in
                p.move(to: CGPoint(x: 70.5 * u, y: 31 * u))
                p.addLine(to: CGPoint(x: 51.5 * u, y: 50 * u))
                p.addLine(to: CGPoint(x: 70.5 * u, y: 69 * u))
            }
            .stroke(MK.Logo.ink, style: StrokeStyle(lineWidth: Mark.stroke * u, lineCap: .round, lineJoin: .round))
            Capsule().fill(MK.Logo.cursor)
                .frame(width: Mark.stemWidth * u, height: Mark.stemHeight * u).offset(x: 25 * u, y: 24.5 * u)
        }
        .frame(width: size, height: size)
        .accessibilityIgnoresInvertColors()   // the mark keeps its colors under Smart Invert
    }

    /// The mark's drawing, in hundredths of the tile (the same as the Mac's AppLogo), not points.
    private enum Mark {
        static let stroke: CGFloat = 12
        static let stemWidth: CGFloat = 14
        static let stemHeight: CGFloat = 51
    }
}
