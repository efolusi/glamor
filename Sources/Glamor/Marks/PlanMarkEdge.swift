import SwiftUI

/// The outline of a `PlanMark`: a hairline capsule, drawn inside the mark's bounds, solid or dashed.
struct PlanMarkEdge: View {
    let mark: PlanMark

    var body: some View {
        Capsule().strokeBorder(mark.edge, style: StrokeStyle(lineWidth: G.Line.hair, dash: mark.dash))
    }
}
