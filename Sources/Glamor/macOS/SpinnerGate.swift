#if os(macOS)
import SwiftUI

/// The spinner rule (MotionSpec) for a spinner its parent removes when the work ends: nothing for
/// delay-spinner (300 ms), then at least hold-spinner (500 ms). While the spinner holds, the parent keeps
/// showing its busy view (`showsBusy`), so a 320 ms answer never flashes a 20 ms spinner.
public struct SpinnerGate: Equatable {
    private(set) var shownAt: ContinuousClock.Instant?
    public var spinnerShown: Bool { shownAt != nil }

    /// The busy view stays while the work runs and while a shown spinner holds.
    public func showsBusy(_ busy: Bool) -> Bool { busy || spinnerShown }

    /// How long to wait, when `busy` changed, before `settle`; nil when nothing changes.
    public func wait(busy: Bool, now: ContinuousClock.Instant) -> Duration? {
        if busy { return spinnerShown ? nil : LoadingTiming.delay }
        guard let shownAt else { return nil }
        return LoadingTiming.holdLeft(shownFor: shownAt.duration(to: now))
    }

    /// After the wait: the spinner shows (busy) or goes (done).
    public mutating func settle(busy: Bool, now: ContinuousClock.Instant) { shownAt = busy ? now : nil }
}

public extension View {
    /// Follows `busy` with the SpinnerGate rule.
    func spinnerGate(_ gate: Binding<SpinnerGate>, busy: Bool) -> some View {
        task(id: busy) {
            guard let wait = gate.wrappedValue.wait(busy: busy, now: .now) else { return }
            if wait > .zero { try? await Task.sleep(for: wait) }
            if Task.isCancelled { return }
            gate.wrappedValue.settle(busy: busy, now: .now)
        }
    }
}

/// Shows `busy` while the work runs and while its spinner holds, then `done`. `busy` gets whether the
/// spinner may show yet (after 300 ms); before that it draws its words with an empty spinner slot, or nothing.
/// Several views in `done` stack with no room between them, as in the tabs' own 0-spaced columns.
public struct HeldLoading<Busy: View, Done: View>: View {
    public let isBusy: Bool
    @ViewBuilder public var busy: (_ spinnerShown: Bool) -> Busy
    @ViewBuilder public var done: () -> Done
    @State private var gate = SpinnerGate()

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if gate.showsBusy(isBusy) { busy(gate.spinnerShown) } else { done() }
        }
        .spinnerGate($gate, busy: isBusy)
    }

    public init(isBusy: Bool, @ViewBuilder busy: @escaping (_ spinnerShown: Bool) -> Busy, @ViewBuilder done: @escaping () -> Done) {
        self.isBusy = isBusy
        self.busy = busy
        self.done = done
    }
}

/// The small spinner's 16 slot: the spinner when `shown`, else the same empty room, so the words beside it
/// never move.
public struct SpinnerSlot: View {
    public let shown: Bool
    public var label: String = "Working"
    public var body: some View {
        ZStack {
            if shown { ProgressView().controlSize(.small).accessibilityLabel(label) }
        }
        .frame(width: G.Icon.md, height: G.Icon.md)
    }

    public init(shown: Bool, label: String = "") {
        self.shown = shown
        self.label = label
    }
}

/// A spinner beside words ("Checking what can go…") while `isBusy`, held by the spinner rule, then `done`.
/// The words show at once; the spinner joins them after 300 ms and stays at least 500 ms.
public struct BusyLine<Done: View>: View {
    public let isBusy: Bool
    public let text: String
    public var label: String = "Working"
    @ViewBuilder public var done: () -> Done

    public var body: some View {
        HeldLoading(isBusy: isBusy) { shown in
            HStack(spacing: G.Space.s8) {
                SpinnerSlot(shown: shown, label: label)
                Text(text).textStyle(.body).foregroundStyle(G.text2)
            }
        } done: { done() }
    }

    public init(isBusy: Bool, text: String, label: String = "", @ViewBuilder done: @escaping () -> Done) {
        self.isBusy = isBusy
        self.text = text
        self.label = label
        self.done = done
    }
}

/// Loading in a host tab: a small spinner over a caption that says what is read ("Reading the services…"),
/// as the cluster logs show it, while `isBusy`; then `done`. Nothing shows for the first 300 ms, and once
/// shown it stays at least 500 ms (MotionSpec), so a fast answer never flashes it. VoiceOver reads the
/// caption once.
public struct ReadingLine<Done: View>: View {
    public let text: String
    public let isBusy: Bool
    public let done: () -> Done

    public init(_ text: String, while isBusy: Bool, @ViewBuilder done: @escaping () -> Done) {
        self.text = text
        self.isBusy = isBusy
        self.done = done
    }

    public var body: some View {
        HeldLoading(isBusy: isBusy) { shown in
            if shown {
                ReadingCaption(text).frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Color.clear
            }
        } done: { done() }
    }
}

/// A check's or a test's state beside its title, in one 16 slot: the spinner while it runs (after 300 ms,
/// held 500 ms), then a check or a cross. The last result stays until the spinner shows, so a fast check
/// never blanks the slot, and the symbol stays in the view, so a new result replaces it over motion-fast.
/// The words beside it are not in this view: they change at once.
public struct RunSymbol: View {
    public let running: Bool
    /// The result: nil before the first one (and while a new run has cleared it).
    public let failed: Bool?
    @State private var last: Bool?
    @State private var gate = SpinnerGate()

    public enum Shown: Equatable {
        case blank, spinner, symbol(failed: Bool)
        public init(running: Bool, last: Bool?, spinnerShown: Bool) {
            if spinnerShown { self = .spinner } else if let last { self = .symbol(failed: last) } else { self = .blank }
        }
    }

    public var body: some View {
        let shown = Shown(running: running, last: last, spinnerShown: gate.spinnerShown)
        let lastFailed = last ?? false
        ZStack {
            Image(systemName: lastFailed ? "xmark.circle.fill" : "checkmark.circle.fill")
                .icon(G.Icon.sm).foregroundStyle(lastFailed ? G.danger : G.ok)
                .contentTransition(.symbolEffect(.replace))
                .gAnimation(.fast, value: lastFailed)
                .opacity(shown == .symbol(failed: lastFailed) ? 1 : 0)
            SpinnerSlot(shown: shown == .spinner, label: "Running")
        }
        .frame(width: G.Icon.md, height: G.Icon.md)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(running ? "Running" : lastFailed ? "Failed" : "Done")
        .spinnerGate($gate, busy: running)
        .onChange(of: running, initial: true) { _, now in if !now, let failed { last = failed } }
        .onChange(of: failed) { _, new in if !running, let new { last = new } }
    }

    public init(running: Bool, failed: Bool?) {
        self.running = running
        self.failed = failed
    }
}
#endif
