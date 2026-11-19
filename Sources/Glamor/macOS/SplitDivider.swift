#if os(macOS)
import SwiftUI

/// The sizes a divider settles on: snapped to the 4-pt scale and kept inside its range.
public enum SplitSize {
    /// The nearest point on the 4-pt scale.
    public static func snap(_ value: CGFloat) -> CGFloat {
        (value / G.Resize.step).rounded() * G.Resize.step
    }

    /// `value` snapped to the scale and kept inside `range`. A bound off the scale (half the page) is
    /// moved inward to the scale, so the result is always a multiple of 4.
    public static func resolve(_ value: CGFloat, in range: ClosedRange<CGFloat>) -> CGFloat {
        let low = (range.lowerBound / G.Resize.step).rounded(.up) * G.Resize.step
        let high = Swift.max(low, (range.upperBound / G.Resize.step).rounded(.down) * G.Resize.step)
        guard value.isFinite else { return low }
        return Swift.min(high, Swift.max(low, snap(value)))
    }

    /// One keyboard or VoiceOver step: 4, or 32 with ⇧.
    public static func step(_ value: CGFloat, by steps: Int, big: Bool = false, in range: ClosedRange<CGFloat>) -> CGFloat {
        resolve(value + CGFloat(steps) * (big ? G.Resize.bigStep : G.Resize.step), in: range)
    }

    /// The tip beside a dragged divider: "288", "224 · smallest" or "400 · largest".
    public static func tip(_ value: CGFloat, in range: ClosedRange<CGFloat>) -> String {
        let n = "\(Int(value))"
        if value <= resolve(range.lowerBound, in: range) { return n + " · smallest" }
        if range.upperBound.isFinite, value >= resolve(range.upperBound, in: range) { return n + " · largest" }
        return n
    }

    /// Which way an arrow key moves the width: +1 grows it, -1 shrinks it. → and ↓ grow the pane before
    /// the divider (`.leading`) and shrink the pane after it (`.trailing`).
    public static func keyDelta(forward: Bool, sizes: SplitDivider.Side) -> Int {
        forward == (sizes == .leading) ? 1 : -1
    }

    /// The width a drag asks for, before it is snapped and kept in range: a drag right (or down) grows the
    /// pane before the divider and shrinks the pane after it.
    public static func dragged(from start: CGFloat, moved: CGFloat, sizes: SplitDivider.Side) -> CGFloat {
        start + (sizes == .leading ? moved : -moved)
    }

    /// True when a drag ends under the smallest width, so an area that can hide (the sidebar) hides.
    public static func collapses(_ asked: CGFloat, in range: ClosedRange<CGFloat>) -> Bool {
        asked < range.lowerBound
    }

    /// The width that shows: the one the person wants (saved or dragged; the default when nil), inside the
    /// room there is now. The wanted width is kept apart, so it comes back when the room grows again.
    public static func shown(wanted: CGFloat?, default value: CGFloat, in range: ClosedRange<CGFloat>) -> CGFloat {
        resolve(wanted ?? value, in: range)
    }

    /// What VoiceOver reads as the value: "272, from 224 to 400", or "900, at least 320" with no largest.
    public static func spoken(_ value: CGFloat, in range: ClosedRange<CGFloat>) -> String {
        let low = Int(resolve(range.lowerBound, in: range))
        guard range.upperBound.isFinite else { return "\(Int(value)), at least \(low)" }
        return "\(Int(value)), from \(low) to \(Int(resolve(range.upperBound, in: range)))"
    }
}

/// Where the app keeps each area's width: one settings key per area, the same in every window and on the
/// next launch. Tests pass their own `UserDefaults` suite; the app uses `.shared`.
public struct SizeStore: @unchecked Sendable {
    public static let shared = SizeStore(defaults: .standard)
    public static let prefix = "size."

    public let defaults: UserDefaults

    /// The saved width for `key`, or `default` when none is saved, inside `range` and on the scale.
    public func load(_ key: String, default value: CGFloat, in range: ClosedRange<CGFloat>) -> CGFloat {
        SplitSize.shown(wanted: saved(key), default: value, in: range)
    }

    /// The width saved for `key` as it was saved, not yet fitted to the room there is now; nil when none is.
    public func saved(_ key: String) -> CGFloat? {
        (defaults.object(forKey: Self.prefix + key) as? NSNumber).map { CGFloat($0.doubleValue) }
    }

    public func save(_ value: CGFloat, for key: String) {
        defaults.set(Double(value), forKey: Self.prefix + key)
    }

    /// Forgets the width, so the area follows its default again (a double-click on the divider).
    public func clear(_ key: String) {
        defaults.removeObject(forKey: Self.prefix + key)
    }

    /// A table's column widths, by column, from 64 to 640.
    public func columns(_ table: String) -> [String: CGFloat] {
        let saved = defaults.dictionary(forKey: Self.prefix + "columns." + table) as? [String: NSNumber] ?? [:]
        return saved.mapValues { SplitSize.resolve(CGFloat($0.doubleValue), in: G.Resize.columnMin...G.Resize.columnMax) }
    }

    public func saveColumn(_ column: String, width: CGFloat?, in table: String) {
        var all = columns(table).mapValues(Double.init)
        all[column] = width.map(Double.init)
        let key = Self.prefix + "columns." + table
        if all.isEmpty { defaults.removeObject(forKey: key) } else { defaults.set(all, forKey: key) }
    }

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }
}

public extension G.ResizeArea {
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
public struct SplitDivider: View {
    public enum Side { case leading, trailing }

    public let axis: Axis
    @Binding public var value: CGFloat
    public let range: ClosedRange<CGFloat>
    public let reset: CGFloat
    /// The settings key it is saved under; nil keeps the width for this window only.
    public var key: String?
    /// What it sizes, for VoiceOver: "Sidebar width", "Transfers height".
    public var label: String
    public var sizes: Side = .leading
    /// False on the sidebar's edge: only the grip shows, under the pointer or while dragging.
    public var hairline: Bool = true
    /// Called when a drag ends below the smallest width (the sidebar hides, as ⌃⌘S does).
    public var onCollapse: (() -> Void)?
    public var store: SizeStore = .shared

    @State private var hover = false
    @State private var dragStart: CGFloat?
    /// The width the person asked for; nil follows the default.
    @State private var wanted: CGFloat?
    @FocusState private var focused: Bool

    public init(axis: Axis, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, default reset: CGFloat, key: String?,
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

    /// The divider for one of the G.Resize areas; `room` is the space there is when it has no largest.
    public init(axis: Axis, value: Binding<CGFloat>, area: G.ResizeArea, room: CGFloat = .infinity, default reset: CGFloat? = nil,
         label: String, sizes: Side = .leading, hairline: Bool = true, onCollapse: (() -> Void)? = nil,
         store: SizeStore = .shared) {
        let range = area.range(room: room)
        self.init(axis: axis, value: value, range: range, default: reset ?? area.defaultSize(room: room), key: area.key,
                  label: label, sizes: sizes, hairline: hairline, onCollapse: onCollapse, store: store)
    }

    private var state: SplitHandle.State {
        dragStart != nil ? .dragging : focused ? .focused : hover ? .hover : .rest
    }

    public var body: some View {
        SplitHandle(axis: axis, state: state, hairline: hairline,
                    tip: dragStart != nil || focused ? SplitSize.tip(value, in: range) : nil)
            .overlay {
                Color.clear
                    .frame(width: axis == .horizontal ? G.Resize.hitArea : nil,
                           height: axis == .vertical ? G.Resize.hitArea : nil)
                    .contentShape(Rectangle())
                    // The sidebar's edge: the hit area sits wholly on the sidebar's side, as its grip does.
                    .offset(x: !hairline && axis == .horizontal ? -G.Resize.hitArea / 2 : 0)
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
public struct SplitHandle: View {
    public enum State { case rest, hover, dragging, focused }

    public let axis: Axis
    public let state: State
    public var hairline: Bool = true
    public var tip: String?
    @Environment(\.colorSchemeContrast) private var contrast

    /// Increase Contrast draws the grip in `text` instead of `text3`.
    private var gripColor: Color {
        if state != .rest { return G.focus }
        return contrast == .increased || IncreasedContrast.forced ? G.text : G.text3
    }

    private var lineColor: Color {
        guard hairline else { return .clear }
        return state == .dragging ? G.focus : G.border
    }

    public var body: some View {
        let across = axis == .horizontal
        Rectangle()
            .fill(lineColor)
            .frame(width: across ? (hairline ? G.Line.hair : 0) : nil, height: across ? nil : G.Line.hair)
            .overlay {
                Capsule()
                    .fill(gripColor)
                    .frame(width: across ? G.Resize.gripThickness : G.Resize.gripLength,
                           height: across ? G.Resize.gripLength : G.Resize.gripThickness)
                    .overlay {
                        // The 2pt focus ring, 2 out from the grip.
                        if state == .focused {
                            Capsule().strokeBorder(G.focus, lineWidth: G.Line.strong)
                                .padding(-(G.Line.focusOffset + G.Line.strong))
                        }
                    }
                    .opacity(hairline || state != .rest ? 1 : 0)
                    .fixedSize()
                    // The sidebar's edge has no line: the grip sits just inside the sidebar, 4 left of the panel.
                    .offset(x: !hairline && across ? -G.Resize.gripThickness / 2 : 0)
            }
            .overlay(alignment: across ? .leading : .top) {
                if let tip {
                    SplitTip(text: tip)
                        .fixedSize()
                        .offset(x: across ? G.Space.s8 : G.Space.s16, y: across ? 0 : G.Space.s8)
                        .frame(width: 0, height: 0, alignment: across ? .leading : .topLeading)
                }
            }
            .allowsHitTesting(false)
    }

    public init(axis: Axis, state: State, hairline: Bool = true, tip: String?) {
        self.axis = axis
        self.state = state
        self.hairline = hairline
        self.tip = tip
    }
}

/// The small mono tip beside a dragged divider: "288", "224 · smallest".
private struct SplitTip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(G.Font.monoS)
            .foregroundStyle(G.text)
            .padding(.horizontal, G.Space.s8)
            .frame(height: G.Height.pill)
            .background(G.panel, in: Capsule())
            .overlay(Capsule().strokeBorder(G.border, lineWidth: G.Line.hair))
            .shadow(G.Shadow.control)
    }
}
#endif
