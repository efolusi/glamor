import SwiftUI

/// The sizes a divider settles on: snapped to the 4-pt scale and kept inside its range.
enum SplitSize {
    /// The nearest point on the 4-pt scale.
    static func snap(_ value: CGFloat) -> CGFloat {
        (value / K.Resize.step).rounded() * K.Resize.step
    }

    /// `value` snapped to the scale and kept inside `range`. A bound off the scale (half the page) is
    /// moved inward to the scale, so the result is always a multiple of 4.
    static func resolve(_ value: CGFloat, in range: ClosedRange<CGFloat>) -> CGFloat {
        let low = (range.lowerBound / K.Resize.step).rounded(.up) * K.Resize.step
        let high = Swift.max(low, (range.upperBound / K.Resize.step).rounded(.down) * K.Resize.step)
        guard value.isFinite else { return low }
        return Swift.min(high, Swift.max(low, snap(value)))
    }

    /// One keyboard or VoiceOver step: 4, or 32 with ⇧.
    static func step(_ value: CGFloat, by steps: Int, big: Bool = false, in range: ClosedRange<CGFloat>) -> CGFloat {
        resolve(value + CGFloat(steps) * (big ? K.Resize.bigStep : K.Resize.step), in: range)
    }

    /// The tip beside a dragged divider: "288", "224 · smallest" or "400 · largest".
    static func tip(_ value: CGFloat, in range: ClosedRange<CGFloat>) -> String {
        let n = "\(Int(value))"
        if value <= resolve(range.lowerBound, in: range) { return n + " · smallest" }
        if range.upperBound.isFinite, value >= resolve(range.upperBound, in: range) { return n + " · largest" }
        return n
    }

    /// Which way an arrow key moves the width: +1 grows it, -1 shrinks it. → and ↓ grow the pane before
    /// the divider (`.leading`) and shrink the pane after it (`.trailing`).
    static func keyDelta(forward: Bool, sizes: SplitDivider.Side) -> Int {
        forward == (sizes == .leading) ? 1 : -1
    }

    /// The width a drag asks for, before it is snapped and kept in range: a drag right (or down) grows the
    /// pane before the divider and shrinks the pane after it.
    static func dragged(from start: CGFloat, moved: CGFloat, sizes: SplitDivider.Side) -> CGFloat {
        start + (sizes == .leading ? moved : -moved)
    }

    /// True when a drag ends under the smallest width, so an area that can hide (the sidebar) hides.
    static func collapses(_ asked: CGFloat, in range: ClosedRange<CGFloat>) -> Bool {
        asked < range.lowerBound
    }

    /// The width that shows: the one the person wants (saved or dragged; the default when nil), inside the
    /// room there is now. The wanted width is kept apart, so it comes back when the room grows again.
    static func shown(wanted: CGFloat?, default value: CGFloat, in range: ClosedRange<CGFloat>) -> CGFloat {
        resolve(wanted ?? value, in: range)
    }

    /// What VoiceOver reads as the value: "272, from 224 to 400", or "900, at least 320" with no largest.
    static func spoken(_ value: CGFloat, in range: ClosedRange<CGFloat>) -> String {
        let low = Int(resolve(range.lowerBound, in: range))
        guard range.upperBound.isFinite else { return "\(Int(value)), at least \(low)" }
        return "\(Int(value)), from \(low) to \(Int(resolve(range.upperBound, in: range)))"
    }
}

/// Where the app keeps each area's width: one settings key per area, the same in every window and on the
/// next launch. Tests pass their own `UserDefaults` suite; the app uses `.shared`.
struct SizeStore: @unchecked Sendable {
    static let shared = SizeStore(defaults: .standard)
    static let prefix = "size."

    let defaults: UserDefaults

    /// The saved width for `key`, or `default` when none is saved, inside `range` and on the scale.
    func load(_ key: String, default value: CGFloat, in range: ClosedRange<CGFloat>) -> CGFloat {
        SplitSize.shown(wanted: saved(key), default: value, in: range)
    }

    /// The width saved for `key` as it was saved, not yet fitted to the room there is now; nil when none is.
    func saved(_ key: String) -> CGFloat? {
        (defaults.object(forKey: Self.prefix + key) as? NSNumber).map { CGFloat($0.doubleValue) }
    }

    func save(_ value: CGFloat, for key: String) {
        defaults.set(Double(value), forKey: Self.prefix + key)
    }

    /// Forgets the width, so the area follows its default again (a double-click on the divider).
    func clear(_ key: String) {
        defaults.removeObject(forKey: Self.prefix + key)
    }

    /// A table's column widths, by column, from 64 to 640.
    func columns(_ table: String) -> [String: CGFloat] {
        let saved = defaults.dictionary(forKey: Self.prefix + "columns." + table) as? [String: NSNumber] ?? [:]
        return saved.mapValues { SplitSize.resolve(CGFloat($0.doubleValue), in: K.Resize.columnMin...K.Resize.columnMax) }
    }

    func saveColumn(_ column: String, width: CGFloat?, in table: String) {
        var all = columns(table).mapValues(Double.init)
        all[column] = width.map(Double.init)
        let key = Self.prefix + "columns." + table
        if all.isEmpty { defaults.removeObject(forKey: key) } else { defaults.set(all, forKey: key) }
    }
}

extension K.ResizeArea {
    /// Where the area starts and what a double-click puts back: its default, or half the room when it has
    /// none (the Files panes, the query, cache and terminal splits), or its smallest when the room is unknown.
    func defaultSize(room: CGFloat = .infinity) -> CGFloat {
        if let ideal { return ideal }
        return room.isFinite ? SplitSize.resolve(room / 2, in: range(room: room)) : min
    }
}

/// The one divider every resizable area uses (SplitDivider card): a 1pt `border` hairline with a 4 by 24
/// grip in `text3`, a 4-wide hit area with the resize cursor, a tip with the width while dragging, snapped to
/// the 4-pt scale and kept in its range. A double-click puts the default back. ← → (↑ ↓ between rows) move it
/// by 4, ⇧ by 32, and Return or Space puts it back, in Full Keyboard Access; VoiceOver reads it as an adjustable
/// element with a Put Back action.
///
/// The width the person wants (saved, dragged or stepped) is kept apart from the width that shows: when the
/// room shrinks for a moment the divider gives way, and when the room grows again the wanted width comes back.
///
/// `axis` is the way it moves: `.horizontal` between side-by-side panes, `.vertical` between stacked ones.
/// `sizes` says which side's width it holds: `.leading` for the pane before it (a list on the left, the queue
/// above), `.trailing` for the pane after it (the agent drawer, the transfer queue below).
struct SplitDivider: View {
    enum Side { case leading, trailing }

    let axis: Axis
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let reset: CGFloat
    /// The settings key it is saved under; nil keeps the width for this window only.
    var key: String?
    /// What it sizes, for VoiceOver: "Sidebar width", "Transfers height".
    var label: String
    var sizes: Side = .leading
    /// False on the sidebar's edge: only the grip shows, under the pointer or while dragging.
    var hairline = true
    /// Called when a drag ends below the smallest width (the sidebar hides, as ⌃⌘S does).
    var onCollapse: (() -> Void)?
    var store: SizeStore = .shared

    @State private var hover = false
    @State private var dragStart: CGFloat?
    /// The width the person asked for; nil follows the default.
    @State private var wanted: CGFloat?
    @FocusState private var focused: Bool

    init(axis: Axis, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, default reset: CGFloat, key: String?,
         label: String, sizes: Side = .leading, hairline: Bool = true, onCollapse: (() -> Void)? = nil,
         store: SizeStore = .shared) {
        self.axis = axis
        _value = value
        self.range = range
        self.reset = reset
        self.key = key
        self.label = label
        self.sizes = sizes
        self.hairline = hairline
        self.onCollapse = onCollapse
        self.store = store
    }

    /// The divider for one of the K.Resize areas; `room` is the space there is when it has no largest.
    init(axis: Axis, value: Binding<CGFloat>, area: K.ResizeArea, room: CGFloat = .infinity, default reset: CGFloat? = nil,
         label: String, sizes: Side = .leading, hairline: Bool = true, onCollapse: (() -> Void)? = nil,
         store: SizeStore = .shared) {
        let range = area.range(room: room)
        self.init(axis: axis, value: value, range: range, default: reset ?? area.defaultSize(room: room), key: area.key,
                  label: label, sizes: sizes, hairline: hairline, onCollapse: onCollapse, store: store)
    }

    private var state: SplitHandle.State {
        dragStart != nil ? .dragging : focused ? .focused : hover ? .hover : .rest
    }

    var body: some View {
        SplitHandle(axis: axis, state: state, hairline: hairline,
                    tip: dragStart != nil || focused ? SplitSize.tip(value, in: range) : nil)
            .overlay {
                Color.clear
                    .frame(width: axis == .horizontal ? K.Resize.hitArea : nil,
                           height: axis == .vertical ? K.Resize.hitArea : nil)
                    .contentShape(Rectangle())
                    // The sidebar's edge: the hit area sits wholly on the sidebar's side, as its grip does.
                    .offset(x: !hairline && axis == .horizontal ? -K.Resize.hitArea / 2 : 0)
                    .pointerStyle(axis == .horizontal ? .columnResize : .rowResize)
                    .onHover { hover = $0 }
                    .onTapGesture(count: 2) { putBack() }
                    .gesture(drag)
                    .help("Drag to resize. Double-click to put it back.")
            }
            .zIndex(1)
            .focusable(interactions: .activate)
            .focusEffectDisabled()
            .focused($focused)
            .onKeyPress(keys: axis == .horizontal ? [.leftArrow, .rightArrow] : [.upArrow, .downArrow]) { press in
                let forward = press.key == .rightArrow || press.key == .downArrow
                move(by: SplitSize.keyDelta(forward: forward, sizes: sizes), big: press.modifiers.contains(.shift))
                return .handled
            }
            .onKeyPress(keys: [.return, .space]) { _ in
                putBack()
                return .handled
            }
            .accessibilityElement()
            .accessibilityLabel(label)
            .accessibilityValue(SplitSize.spoken(value, in: range))
            .accessibilityHint("Put Back returns it to \(Int(SplitSize.resolve(reset, in: range))).")
            .accessibilityAction(named: "Put Back") { putBack() }
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: move(by: 1)
                case .decrement: move(by: -1)
                @unknown default: break
                }
            }
            .onAppear {
                if let key { wanted = store.saved(key) } else { wanted = value }
                fit()
            }
            // The room changed (the window, the page): show the wanted width again, as far as it fits.
            .onChange(of: [range.lowerBound, range.upperBound, reset]) { fit() }
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .global)
            .onChanged { g in
                let start = dragStart ?? value
                dragStart = start
                let moved = axis == .horizontal ? g.translation.width : g.translation.height
                value = SplitSize.resolve(SplitSize.dragged(from: start, moved: moved, sizes: sizes), in: range)
            }
            .onEnded { g in
                let start = dragStart ?? value
                dragStart = nil
                let moved = axis == .horizontal ? g.translation.width : g.translation.height
                if let onCollapse, SplitSize.collapses(SplitSize.dragged(from: start, moved: moved, sizes: sizes), in: range) {
                    onCollapse()
                    return
                }
                save()
            }
    }

    private func move(by steps: Int, big: Bool = false) {
        value = SplitSize.step(value, by: steps, big: big, in: range)
        save()
    }

    private func putBack() {
        wanted = nil
        fit()
        if let key { store.clear(key) }
    }

    private func fit() {
        let shown = SplitSize.shown(wanted: wanted, default: reset, in: range)
        if shown != value { value = shown }
    }

    /// The width shown now is what the person wants from here on.
    private func save() {
        wanted = value
        if let key { store.save(value, for: key) }
    }
}

/// How a SplitDivider looks in each state, drawn on its own so the design gallery can show every state.
struct SplitHandle: View {
    enum State { case rest, hover, dragging, focused }

    let axis: Axis
    let state: State
    var hairline = true
    var tip: String?
    @Environment(\.colorSchemeContrast) private var contrast

    /// Increase Contrast draws the grip in `text` instead of `text3`.
    private var gripColor: Color {
        if state != .rest { return K.accent }
        return contrast == .increased || IncreasedContrast.forced ? K.text : K.text3
    }

    private var lineColor: Color {
        guard hairline else { return .clear }
        return state == .dragging ? K.accent : K.border
    }

    var body: some View {
        let across = axis == .horizontal
        Rectangle()
            .fill(lineColor)
            .frame(width: across ? (hairline ? K.Line.hair : 0) : nil, height: across ? nil : K.Line.hair)
            .overlay {
                Capsule()
                    .fill(gripColor)
                    .frame(width: across ? K.Resize.gripThickness : K.Resize.gripLength,
                           height: across ? K.Resize.gripLength : K.Resize.gripThickness)
                    .overlay {
                        // The 2pt focus ring, 2 out from the grip.
                        if state == .focused {
                            Capsule().strokeBorder(K.focus, lineWidth: K.Line.strong)
                                .padding(-(K.Line.focusOffset + K.Line.strong))
                        }
                    }
                    .opacity(hairline || state != .rest ? 1 : 0)
                    .fixedSize()
                    // The sidebar's edge has no line: the grip sits just inside the sidebar, 4 left of the panel.
                    .offset(x: !hairline && across ? -K.Resize.gripThickness / 2 : 0)
            }
            .overlay(alignment: across ? .leading : .top) {
                if let tip {
                    SplitTip(text: tip)
                        .fixedSize()
                        .offset(x: across ? K.Space.s8 : K.Space.s16, y: across ? 0 : K.Space.s8)
                        .frame(width: 0, height: 0, alignment: across ? .leading : .topLeading)
                }
            }
            .allowsHitTesting(false)
    }
}

/// The small mono tip beside a dragged divider: "288", "224 · smallest".
private struct SplitTip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(K.Font.monoS)
            .foregroundStyle(K.text)
            .padding(.horizontal, K.Space.s8)
            .frame(height: K.Height.pill)
            .background(K.panel, in: Capsule())
            .overlay(Capsule().strokeBorder(K.border, lineWidth: K.Line.hair))
            .shadow(K.Shadow.control)
    }
}
