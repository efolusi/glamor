#if os(macOS)
import SwiftUI

/// Prints what SwiftUI hands the views, so a script can see which glass path Glamor will take.
struct EnvironmentProbe: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast
    var body: some View {
        Color.clear.onAppear {
            if Options.logActivations {
                print("environment: contrast=\(contrast == .increased ? "increased" : "standard") reduceTransparency=\(reduceTransparency)")
                fflush(stdout)
            }
        }
    }
}
#endif
