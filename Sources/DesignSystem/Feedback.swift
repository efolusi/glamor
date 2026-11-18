import AppKit
import GlamorText
import SwiftUI

// How the app says what happened: banners in place, empty states, and output from komando.

/// A message in place, above what it is about (design system: Banner). 12 inside, radius 8, the
/// status color at 10%; a danger banner adds a ring of its color at 25%.
struct Banner<Actions: View>: View {
    enum Kind { case success, warning, danger, info }
    let kind: Kind
    let title: String
    var detail: String?
    @ViewBuilder var actions: () -> Actions

    private var color: Color {
        switch kind {
        case .success: K.ok
        case .warning: K.warn
        case .danger: K.danger
        case .info: K.accent
        }
    }

    private var symbol: String {
        switch kind {
        case .success: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .danger: "exclamationmark.circle.fill"
        case .info: "info.circle.fill"
        }
    }

    /// What VoiceOver reads before the title, so the kind is not told by color and shape alone.
    static func spokenKind(_ kind: Kind) -> String {
        switch kind {
        case .success: "Done"
        case .warning: "Warning"
        case .danger: "Error"
        case .info: "Note"
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: K.Space.s8) {
            Image(systemName: symbol).icon(K.Icon.i16, label: Self.spokenKind(kind)).foregroundStyle(color)
                .frame(maxHeight: .infinity, alignment: .top)
            VStack(alignment: .leading, spacing: K.Space.s2) {
                Text(DisplayText.line(title)).fontWeight(.medium).foregroundStyle(K.text).textSelection(.enabled)
                    .frame(minHeight: K.Height.line16)
                if let detail, !detail.isEmpty {
                    Text(DisplayText.clean(detail)).foregroundStyle(K.text2).textSelection(.enabled)
                }
            }
            // The text takes the room itself: a Spacer here would cost the HStack's 8 even with no actions,
            // and the detail would wrap earlier than the card's (12 inside, 16 icon, 8, text to the edge).
            .frame(maxWidth: .infinity, alignment: .leading)
            actions().controlSize(.small)
        }
        .textStyle(.caption)
        .fixedSize(horizontal: false, vertical: true)
        .padding(K.Space.s12)
        .background(color.opacity(K.Opacity.banner), in: RoundedRectangle(cornerRadius: K.Radius.r8, style: .continuous))
        .overlay {
            if kind == .danger {
                RoundedRectangle(cornerRadius: K.Radius.r8, style: .continuous)
                    .strokeBorder(color.opacity(K.Opacity.bannerEdge), lineWidth: K.Line.hair)
            }
        }
    }
}

extension Banner where Actions == EmptyView {
    init(_ kind: Kind, _ title: String, detail: String? = nil) {
        self.init(kind: kind, title: title, detail: detail) { EmptyView() }
    }
}

/// An error with its hint. Product-specific error banners (next steps, details) live in the app.
struct ErrorBanner: View {
    let title: String
    let hint: String?

    var body: some View { Banner(.danger, title, detail: hint) }
}

/// Centred, quiet: an icon, a title, a line or two, and at most one primary action.
struct EmptyState<Actions: View>: View {
    let symbol: String
    let title: String
    var message: String = ""
    @ViewBuilder var actions: () -> Actions

    var body: some View {
        VStack(spacing: K.Space.s8) {
            Image(systemName: symbol).icon(K.Icon.i32, weight: .light).foregroundStyle(K.text3)
                .padding(.bottom, K.Space.s4)
                .accessibilityHidden(true)
            Text(title).textStyle(.titleS).foregroundStyle(K.text).multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            if !message.isEmpty {
                Text(message).textStyle(.body).foregroundStyle(K.text2)
                    .multilineTextAlignment(.center).frame(maxWidth: K.Width.message)
            }
            actions().padding(.top, K.Space.s8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(K.Space.s40)
    }
}

extension EmptyState where Actions == EmptyView {
    init(symbol: String, title: String, message: String = "") {
        self.init(symbol: symbol, title: title, message: message) { EmptyView() }
    }
}

/// "Nothing is running." in a section: one quiet line, not a whole empty state.
struct QuietLine: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text).textStyle(.body).foregroundStyle(K.text3)
            .frame(maxWidth: .infinity, minHeight: K.Height.row40, alignment: .leading)
    }
}

/// A block of komando's output, without escape codes or control characters (a server wrote it).
struct OutputText: View {
    let text: String
    var color: Color = K.text
    var body: some View {
        let shown = DisplayText.clean(text)
        Text(shown.hasSuffix("\n") ? String(shown.dropLast()) : shown)
            .textStyle(.mono)
            .foregroundStyle(color)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(K.Space.s12)
            .surface()
    }
}

/// ProgressBar: a 4-high capsule on `border`, filled with its tone (`accent` while in progress, `ok`
/// when complete or healthy, `warn` when nearly full). The number always sits beside it.
struct ProgressBar: View {
    /// 0…1.
    let value: Double
    var tone: Color = K.accent
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule().fill(K.border)
                Capsule().fill(tone).frame(width: g.size.width * min(max(value, 0), 1))
                    .kAnimation(.progress, value: value)   // motion-progress: never jumps (it does with Reduce Motion)
            }
        }
        .frame(height: K.Line.bar)
        .accessibilityElement()
        .accessibilityValue("\(Int((min(max(value, 0), 1) * 100).rounded())) percent")
    }
}

// MARK: Waiting and copying (MotionSpec)

/// When a spinner or skeleton may show (MotionSpec): only after delay-spinner (300 ms) of work, so fast
/// work never flashes one, and once shown for at least hold-spinner (500 ms), so it never flickers.
/// Every spinner gate (DelayedLoading, SpinnerGate, WaitHold) takes its times from here, so they all
/// behave alike. With K.Motion off (debug snapshots) both are zero.
enum LoadingTiming {
    /// How long work runs before its spinner may show.
    static var delay: Duration { K.Motion.isOff ? .zero : K.Motion.spinnerDelay }

    /// How much longer something shown for `shownFor` must stay once the work is done.
    static func holdLeft(shownFor: Duration) -> Duration {
        K.Motion.isOff ? .zero : max(.zero, K.Motion.spinnerHold - shownFor)
    }
}

/// Shows `content` (a spinner, a skeleton) while `isBusy`, by the LoadingTiming rule. With
/// `reservesSpace`, the room it takes stays when it is hidden, so the words beside it never shift.
struct DelayedLoading<Content: View>: View {
    let isBusy: Bool
    var reservesSpace = false
    @ViewBuilder var content: () -> Content
    @State private var shown = false
    @State private var shownAt = ContinuousClock.now

    var body: some View {
        ZStack {
            if shown { content() } else if reservesSpace { content().hidden().accessibilityHidden(true) }
        }
        .task(id: isBusy) {
            if isBusy {
                guard !shown else { return }
                try? await Task.sleep(for: LoadingTiming.delay)
                if Task.isCancelled { return }
                shownAt = .now
                shown = true
            } else if shown {
                try? await Task.sleep(for: LoadingTiming.holdLeft(shownFor: shownAt.duration(to: .now)))
                if Task.isCancelled { return }
                shown = false
            }
        }
    }
}

/// The small spinner, by the LoadingTiming rule: nothing for 300 ms, then at least 500 ms. Its 16
/// square stays, so the words beside it never move.
struct DelayedProgress: View {
    let isBusy: Bool
    var label = "Working"
    var body: some View {
        DelayedLoading(isBusy: isBusy, reservesSpace: true) {
            ProgressView().controlSize(.small).accessibilityLabel(label)
        }
        .frame(width: K.Icon.i16, height: K.Icon.i16)
    }
}

/// Skeleton: a still `subtle` placeholder for a line of text (12 for caption, 16 for body) or a tile.
/// No shimmer (owner decision 2026-11-15). Put it inside DelayedLoading so a fast load shows nothing.
struct Skeleton: View {
    let width: CGFloat
    var height: CGFloat = K.Space.s12
    var body: some View {
        RoundedRectangle(cornerRadius: K.Radius.r4, style: .continuous).fill(K.subtle)
            .frame(width: width, height: height)
            .accessibilityHidden(true)
    }
}

/// CopyButton: a 24 ghost icon button that copies `text`. Its `square.on.square` is replaced by a
/// `checkmark` in `ok` over motion-fast and comes back after hold-confirm (1.5 s); VoiceOver says
/// "Copied". Copying never happens silently (MotionSpec).
struct CopyButton: View {
    let text: String
    var help = "Copy"
    var size: CGFloat = K.Height.control24
    @State private var copied = false
    @State private var copies = 0
    @State private var hover = false

    /// The text as it is, minus the control characters a terminal acts on (line breaks and tabs stay).
    private static func copyToPasteboard(_ s: String) {
        var out = String.UnicodeScalarView()
        out.append(contentsOf: s.unicodeScalars.filter {
            switch $0.value {
            case 0x09, 0x0A, 0x0D: true
            case 0x00...0x1F, 0x7F...0x9F: false
            default: true
            }
        })
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(String(out), forType: .string)
    }

    var body: some View {
        Button {
            Self.copyToPasteboard(text)
            copied = true
            copies += 1
            AccessibilityNotification.Announcement("Copied").post()
        } label: {
            Image(systemName: copied ? "checkmark" : "square.on.square")
                .contentTransition(.symbolEffect(.replace))
                .fontWeight(copied ? .semibold : .regular)
                .foregroundStyle(copied ? K.ok : (hover ? K.text : K.text2))
        }
        .buttonStyle(GhostButtonStyle(square: true, size: size))
        .onHover { hover = $0 }
        .kAnimation(.fast, value: copied)
        .help(copied ? "Copied" : help)
        .accessibilityLabel(copied ? "Copied" : help)
        .task(id: copies) {
            guard copied else { return }
            try? await Task.sleep(for: K.Motion.confirmHold)
            if !Task.isCancelled { copied = false }
        }
    }
}

/// A small spinner with what it waits for in a caption ("Reading the tables…"), as ClusterLogsTab draws it.
/// VoiceOver reads the caption, so the wait is never an unnamed spinner. It draws at once: the caller shows it
/// while `.waitHold(_:shown:)` says so, or through ReadingLine (the host tabs), both by the LoadingTiming rule
/// (MotionSpec, delay-spinner and hold-spinner).
struct ReadingCaption: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        VStack(spacing: K.Space.s8) {
            ProgressView().controlSize(.small).accessibilityHidden(true)
            Text(text).textStyle(.caption).foregroundStyle(K.text3)
        }
        .accessibilityElement(children: .combine)
    }
}

/// When a waiting moment comes and goes, by the LoadingTiming rule: nothing for delay-spinner (300 ms), then
/// on screen for at least hold-spinner (500 ms), even when the work ends just after it showed.
///
/// The work's own flag cannot drive this: the view that shows the wait usually goes away the moment the work
/// ends, so a wait shown at 300 ms would vanish at 320 ms. The caller keeps `shown` and shows the wait (and
/// holds back what replaces it) while it is true.
enum WaitHold {
    enum Step: Equatable {
        case show(after: Duration)
        case hide(after: Duration)
    }

    /// What to do next. `shownFor` is how long the wait has been on screen.
    static func step(isBusy: Bool, shown: Bool, shownFor: Duration) -> Step? {
        if isBusy { return shown ? nil : .show(after: LoadingTiming.delay) }
        return shown ? .hide(after: LoadingTiming.holdLeft(shownFor: shownFor)) : nil
    }
}

private struct WaitHoldModifier: ViewModifier {
    let isBusy: Bool
    @Binding var shown: Bool
    @State private var shownAt = ContinuousClock.now

    func body(content: Content) -> some View {
        content.task(id: isBusy) {
            switch WaitHold.step(isBusy: isBusy, shown: shown, shownFor: shownAt.duration(to: .now)) {
            case .show(let after)?:
                try? await Task.sleep(for: after)
                if Task.isCancelled { return }
                shownAt = .now
                shown = true
            case .hide(let after)?:
                try? await Task.sleep(for: after)
                if Task.isCancelled { return }
                shown = false
            case nil:
                break
            }
        }
    }
}

extension View {
    /// Sets `shown` by the WaitHold rule while `isBusy` comes and goes. Put it on a view that stays on screen
    /// for the whole wait (the list, not the overlay that shows the spinner).
    func waitHold(_ isBusy: Bool, shown: Binding<Bool>) -> some View {
        modifier(WaitHoldModifier(isBusy: isBusy, shown: shown))
    }
}
