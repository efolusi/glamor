import SwiftUI

/// The spinner rule (MotionSpec) for a spinner its parent removes when the work ends: nothing for
/// delay-spinner (300 ms), then at least hold-spinner (500 ms). While the spinner holds, the parent keeps
/// showing its busy view (`showsBusy`), so a 320 ms answer never flashes a 20 ms spinner.
struct SpinnerGate: Equatable {
    private(set) var shownAt: ContinuousClock.Instant?
    var spinnerShown: Bool { shownAt != nil }

    /// The busy view stays while the work runs and while a shown spinner holds.
    func showsBusy(_ busy: Bool) -> Bool { busy || spinnerShown }

    /// How long to wait, when `busy` changed, before `settle`; nil when nothing changes.
    func wait(busy: Bool, now: ContinuousClock.Instant) -> Duration? {
        if busy { return spinnerShown ? nil : LoadingTiming.delay }
        guard let shownAt else { return nil }
        return LoadingTiming.holdLeft(shownFor: shownAt.duration(to: now))
    }

    /// After the wait: the spinner shows (busy) or goes (done).
    mutating func settle(busy: Bool, now: ContinuousClock.Instant) { shownAt = busy ? now : nil }
}

extension View {
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
struct HeldLoading<Busy: View, Done: View>: View {
    let isBusy: Bool
    @ViewBuilder var busy: (_ spinnerShown: Bool) -> Busy
    @ViewBuilder var done: () -> Done
    @State private var gate = SpinnerGate()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if gate.showsBusy(isBusy) { busy(gate.spinnerShown) } else { done() }
        }
        .spinnerGate($gate, busy: isBusy)
    }
}

/// The small spinner's 16 slot: the spinner when `shown`, else the same empty room, so the words beside it
/// never move.
struct SpinnerSlot: View {
    let shown: Bool
    var label = "Working"
    var body: some View {
        ZStack {
            if shown { ProgressView().controlSize(.small).accessibilityLabel(label) }
        }
        .frame(width: K.Icon.i16, height: K.Icon.i16)
    }
}

/// A spinner beside words ("Checking what can go…") while `isBusy`, held by the spinner rule, then `done`.
/// The words show at once; the spinner joins them after 300 ms and stays at least 500 ms.
struct BusyLine<Done: View>: View {
    let isBusy: Bool
    let text: String
    var label = "Working"
    @ViewBuilder var done: () -> Done

    var body: some View {
        HeldLoading(isBusy: isBusy) { shown in
            HStack(spacing: K.Space.s8) {
                SpinnerSlot(shown: shown, label: label)
                Text(text).textStyle(.body).foregroundStyle(K.text2)
            }
        } done: { done() }
    }
}

/// Loading in a host tab: a small spinner over a caption that says what is read ("Reading the services…"),
/// as the cluster logs show it, while `isBusy`; then `done`. Nothing shows for the first 300 ms, and once
/// shown it stays at least 500 ms (MotionSpec), so a fast answer never flashes it. VoiceOver reads the
/// caption once.
struct ReadingLine<Done: View>: View {
    let text: String
    let isBusy: Bool
    let done: () -> Done

    init(_ text: String, while isBusy: Bool, @ViewBuilder done: @escaping () -> Done) {
        self.text = text
        self.isBusy = isBusy
        self.done = done
    }

    var body: some View {
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
struct RunSymbol: View {
    let running: Bool
    /// The result: nil before the first one (and while a new run has cleared it).
    let failed: Bool?
    @State private var last: Bool?
    @State private var gate = SpinnerGate()

    enum Shown: Equatable {
        case blank, spinner, symbol(failed: Bool)
        init(running: Bool, last: Bool?, spinnerShown: Bool) {
            if spinnerShown { self = .spinner } else if let last { self = .symbol(failed: last) } else { self = .blank }
        }
    }

    var body: some View {
        let shown = Shown(running: running, last: last, spinnerShown: gate.spinnerShown)
        let lastFailed = last ?? false
        ZStack {
            Image(systemName: lastFailed ? "xmark.circle.fill" : "checkmark.circle.fill")
                .icon(K.Icon.i12).foregroundStyle(lastFailed ? K.danger : K.ok)
                .contentTransition(.symbolEffect(.replace))
                .kAnimation(.fast, value: lastFailed)
                .opacity(shown == .symbol(failed: lastFailed) ? 1 : 0)
            SpinnerSlot(shown: shown == .spinner, label: "Running")
        }
        .frame(width: K.Icon.i16, height: K.Icon.i16)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(running ? "Running" : lastFailed ? "Failed" : "Done")
        .spinnerGate($gate, busy: running)
        .onChange(of: running, initial: true) { _, now in if !now, let failed { last = failed } }
        .onChange(of: failed) { _, new in if !running, let new { last = new } }
    }
}
