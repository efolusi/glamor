#if os(macOS)
import Glamor
import SwiftUI

/// The Pro and Soon marks (GL36), each twice: on the window and on a card, the two grounds a mark sits on inside a page.
/// A mark has no control of its own, so this scene's list in scripts/window/WindowCheck.swift has no controls: it reads
/// the marks' words, outlines and spoken names. The window is the components scene's panel ground.
struct MarksScene: View {
    var body: some View {
        VStack(alignment: .leading, spacing: G.Space.s16) {
            rows
            VStack(alignment: .leading, spacing: G.Space.s16) { rows }
                .padding(G.Space.s16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .card()
        }
        .textStyle(.body)
        .foregroundStyle(G.text)
        .padding(G.Space.s24)
        .frame(width: 460, height: 260, alignment: .topLeading)
        .background(G.panel)
    }

    /// The names are the gallery's own demo words, not a product's.
    @ViewBuilder private var rows: some View {
        HStack(spacing: G.Space.s8) { Text(Words.text("marks.sync")); Pill(mark: .pro) }
        HStack(spacing: G.Space.s8) { Text(Words.text("marks.approvals")); Pill(mark: .soon) }
    }
}
#endif
