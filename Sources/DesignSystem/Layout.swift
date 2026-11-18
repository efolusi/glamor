import SwiftUI

// Page containers: a page scrolls inside the panel with 32 at the sides, 24 top and bottom and 24
// between sections; a form is a centred column.

let cardGrid = [GridItem(.adaptive(minimum: K.Width.cardMin, maximum: K.Width.cardMax), spacing: K.Space.s16)]
// Two columns whose fields share a top line, so a two-line help never pushes its neighbour down (PageNewConnection).
let twoColumns = [GridItem(.flexible(), spacing: K.Space.s16, alignment: .topLeading), GridItem(.flexible(), spacing: K.Space.s16, alignment: .topLeading)]

struct Page<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: K.Space.s24) { content() }
                .padding(.horizontal, K.Space.s32).padding(.vertical, K.Space.s24)
                .frame(maxWidth: K.Width.pageMax, alignment: .leading)
                .frame(maxWidth: .infinity)
        }
        .scrollContentBackground(.hidden)
    }
}

/// A section of a page: its title, a line under it, and a link on the right.
struct PageSection<Content: View, Trailing: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder var trailing: () -> Trailing
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: K.Space.s16) {
            HStack(alignment: .top, spacing: K.Space.s8) {
                SectionTitle(title, subtitle: subtitle)
                Spacer(minLength: K.Space.s8)
                trailing()
            }
            content()
        }
    }
}

extension PageSection where Trailing == EmptyView {
    init(_ title: String, subtitle: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.init(title: title, subtitle: subtitle, trailing: { EmptyView() }, content: content)
    }
}

/// A centred column for a form (design system: PageNewHost): at most 640 wide with its 32 sides
/// included, 24 top and bottom, fields 16 apart.
struct FormPage<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: K.Space.s16) { content() }
                .padding(.horizontal, K.Space.s32).padding(.vertical, K.Space.s24)
                .frame(maxWidth: K.Width.form, alignment: .leading)
                .frame(maxWidth: .infinity)
        }
        .scrollContentBackground(.hidden)
    }
}

/// The top of a form: a 48 tile 12 before the title and its one line. The form's 16 sets the gap under it.
struct FormHeader: View {
    let symbol: String
    let tint: Color
    let title: String
    let subtitle: String
    var body: some View {
        HStack(spacing: K.Space.s12) {
            IconTile(symbol: symbol, tint: tint, size: K.Tile.t48)
            VStack(alignment: .leading, spacing: K.Space.s2) {
                Text(title).textStyle(.titleL).accessibilityAddTraits(.isHeader)
                Text(subtitle).textStyle(.body).foregroundStyle(K.text2)
            }
        }
    }
}

extension View {
    /// Escape runs `action`, for a sheet whose only button is Done or Close (that button keeps Return).
    /// A sheet with a Cancel button gives that button `.keyboardShortcut(.cancelAction)` instead.
    func closesOnEscape(_ action: @escaping () -> Void) -> some View {
        background {
            Button("Close", action: action).keyboardShortcut(.cancelAction).hidden()
        }
    }
}

/// A sheet a person can resize by its edges: never smaller than `min`, opening at `ideal`, as large as the
/// screen.
struct SheetResize: Equatable {
    let min: CGSize
    let ideal: CGSize

    /// The Edit File sheet: 520 by 480 when it opens, never under 520 by 320.
    static let editFile = SheetResize(min: K.Resize.editSheetMin, ideal: K.Resize.editSheetIdeal)
}

/// A sheet on the panel color: head, body, then Cancel and the primary on the right. Escape must close
/// every sheet: the caller's Cancel carries `.keyboardShortcut(.cancelAction)`, and a sheet with no Cancel
/// adds `.closesOnEscape { ... }`.
struct SheetLayout<Content: View, Status: View, Buttons: View>: View {
    let symbol: String
    var tint: Color = K.accent
    let title: String
    var subtitle: String?
    var width: CGFloat = K.Width.sheet
    /// nil: `width` wide and as tall as the body. Set: the sheet resizes, and the body fills the room, so
    /// its content does its own scrolling (a text editor, a log).
    var resize: SheetResize?
    @ViewBuilder var content: () -> Content
    /// What a save said (an ErrorBanner): 20 under the body, outside its scroll, so it is always in view.
    @ViewBuilder var status: () -> Status
    @ViewBuilder var buttons: () -> Buttons

    var body: some View {
        VStack(alignment: .leading, spacing: K.Space.s20) {
            HStack(spacing: K.Space.s12) {
                IconTile(symbol: symbol, tint: tint, size: K.Tile.t48)
                VStack(alignment: .leading, spacing: K.Space.s2) {
                    Text(title).textStyle(.titleL).accessibilityAddTraits(.isHeader)
                    if let subtitle { Text(subtitle).textStyle(.caption).foregroundStyle(K.text2) }
                }
            }
            if resize != nil {
                fields.frame(maxHeight: .infinity, alignment: .top)
            } else {
                // Taller than the window (Edit Host with More open on a laptop): the body scrolls, and the
                // head and the buttons stay in view.
                ViewThatFits(in: .vertical) {
                    fields
                    ScrollViewReader { proxy in
                        ScrollView {
                            fields
                            Color.clear.frame(height: 0).id(Self.endID)
                        }
                        .scrollBounceBehavior(.basedOnSize)
                        #if DEBUG
                        // KOMANDO_APP_SCROLL=end: a snapshot of what sits below the fold (Edit Host's More).
                        .onAppear {
                            guard ProcessInfo.processInfo.environment["KOMANDO_APP_SCROLL"] == "end" else { return }
                            // After the sheet's first layout, so the end is there to scroll to.
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { proxy.scrollTo(Self.endID, anchor: .bottom) }
                        }
                        #endif
                    }
                }
            }
            status()
            HStack(spacing: K.Space.s8) { buttons() }
        }
        .padding(K.Space.s24)
        .modifier(SheetFrame(width: width, resize: resize))
        .background(K.panel)
    }

    private static var endID: String { "sheet-end" }

    private var fields: some View {
        VStack(alignment: .leading, spacing: K.Space.s16) { content() }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A fixed width, or the smallest, first and largest size of a resizable sheet. A frame whose largest size is
/// more than its smallest should make macOS give the sheet resizable edges; no sheet passes `resize:` yet
/// (Edit File, in Files, is the first), so this path has no render until then.
private struct SheetFrame: ViewModifier {
    let width: CGFloat
    let resize: SheetResize?
    func body(content: Content) -> some View {
        if let r = resize {
            content.frame(minWidth: r.min.width, idealWidth: r.ideal.width, maxWidth: .infinity,
                          minHeight: r.min.height, idealHeight: r.ideal.height, maxHeight: .infinity, alignment: .topLeading)
        } else {
            content.frame(width: width)
        }
    }
}

extension SheetLayout where Status == EmptyView {
    init(symbol: String, tint: Color = K.accent, title: String, subtitle: String? = nil, width: CGFloat = K.Width.sheet,
         resize: SheetResize? = nil, @ViewBuilder content: @escaping () -> Content, @ViewBuilder buttons: @escaping () -> Buttons) {
        self.init(symbol: symbol, tint: tint, title: title, subtitle: subtitle, width: width, resize: resize,
                  content: content, status: { EmptyView() }, buttons: buttons)
    }
}
