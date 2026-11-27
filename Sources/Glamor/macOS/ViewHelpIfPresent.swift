#if os(macOS)
import SwiftUI

extension View {
    /// `help(_:)` only when there is a text: an empty or absent tooltip must not become the control's help text.
    @ViewBuilder func help(ifPresent text: String?) -> some View {
        if let text { help(text) } else { self }
    }
}
#endif
