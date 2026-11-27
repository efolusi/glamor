#if os(iOS)
import SwiftUI

public extension View {
    /// A selected row: a capsule in `selectedMarker`, `G.Row.markerWidth` wide and `G.Row.markerHeight` of the row's
    /// height, centred, `G.Row.markerInset` in from the leading edge. The fill alone is faint, so the capsule says it
    /// by shape too. The same call and the same measures as the Mac's.
    func selectedMarker(_ on: Bool) -> some View {
        overlay(alignment: .leading) {
            if on {
                GeometryReader { row in
                    Capsule().fill(G.selectedMarker)
                        .frame(width: G.Row.markerWidth, height: row.size.height * G.Row.markerHeight)
                        .frame(maxHeight: .infinity)
                        .padding(.leading, G.Row.markerInset)
                }
                .accessibilityHidden(true)
            }
        }
    }
}
#endif
