#if os(macOS)
import SwiftUI

/// A titled block of places that folds: a 32 high header (title in section-label type, a chevron) over its rows.
/// Two ways to hold the open state, because `SceneStorage` needs a running scene and a view hosted in a bare
/// `NSHostingView` (the gallery) has none:
/// - `isExpanded:` the caller's binding, kept wherever the caller keeps it;
/// - `id:` the state is kept per window in `SceneStorage`, under `storageKey(id:)`.
/// A folded section's rows are not drawn, so they leave the accessibility tree and the Tab order.
public struct SidebarSection<Content: View>: View {
    public let title: String
    private let storage: Storage
    private let content: Content

    private enum Storage {
        case binding(Binding<Bool>)
        case scene(id: String, startsExpanded: Bool)
    }

    public init(_ title: String, isExpanded: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.title = title
        storage = .binding(isExpanded)
        self.content = content()
    }

    public init(_ title: String, id: String, startsExpanded: Bool = true, @ViewBuilder content: () -> Content) {
        self.title = title
        storage = .scene(id: id, startsExpanded: startsExpanded)
        self.content = content()
    }

    /// The `SceneStorage` key of the section with this id.
    static func storageKey(id: String) -> String { "glamor.sidebar.section.\(id)" }

    public var body: some View {
        switch storage {
        case .binding(let isExpanded):
            SidebarSectionBody(title: title, isExpanded: isExpanded) { content }
        case .scene(let id, let startsExpanded):
            SidebarSectionStored(title: title, id: id, startsExpanded: startsExpanded) { content }
        }
    }
}
#endif
