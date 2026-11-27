#if os(macOS)
import SwiftUI

/// `SidebarSection` with its open state in `SceneStorage`. Only built by `SidebarSection.init(_:id:)`.
struct SidebarSectionStored<Content: View>: View {
    let title: String
    @SceneStorage private var isExpanded: Bool
    private let content: Content

    init(title: String, id: String, startsExpanded: Bool, @ViewBuilder content: () -> Content) {
        self.title = title
        _isExpanded = SceneStorage(wrappedValue: startsExpanded, SidebarSection<Content>.storageKey(id: id))
        self.content = content()
    }

    var body: some View {
        SidebarSectionBody(title: title, isExpanded: $isExpanded) { content }
    }
}
#endif
