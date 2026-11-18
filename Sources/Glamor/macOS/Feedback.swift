#if os(macOS)
import AppKit
import SwiftUI

// How the app says what happened: banners in place, empty states, and command output.

/// A message in place, above what it is about (design system: Banner). 12 inside, radius 8, the
/// status color at 10%; a danger banner adds a ring of its color at 25%.
public struct Banner<Actions: View>: View {
    public enum Kind { case success, warning, danger, info }
    public let kind: Kind
    public let title: String
    public var detail: String?
    @ViewBuilder public var actions: () -> Actions

    private var color: Color {
        switch kind {
        case .success: G.ok
        case .warning: G.warn
        case .danger: G.danger
        case .info: G.accent
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
    public static func spokenKind(_ kind: Kind) -> String {
        switch kind {
        case .success: "Done"
        case .warning: "Warning"
        case .danger: "Error"
        case .info: "Note"
        }
    }

    public var body: some View {
        HStack(alignment: .center, spacing: G.Space.s8) {
            Image(systemName: symbol).icon(G.Icon.md, label: Self.spokenKind(kind)).foregroundStyle(color)
                .frame(maxHeight: .infinity, alignment: .top)
            VStack(alignment: .leading, spacing: G.Space.s2) {
                Text(DisplayText.line(title)).fontWeight(.medium).foregroundStyle(G.text).textSelection(.enabled)
                    .frame(minHeight: G.Height.line16)
                if let detail, !detail.isEmpty {
                    Text(DisplayText.clean(detail)).foregroundStyle(G.text2).textSelection(.enabled)
                }
            }
            // The text takes the room itself: a Spacer here would cost the HStack's 8 even with no actions,
            // and the detail would wrap earlier than the card's (12 inside, 16 icon, 8, text to the edge).
            .frame(maxWidth: .infinity, alignment: .leading)
            actions().controlSize(.small)
        }
        .textStyle(.caption)
        .fixedSize(horizontal: false, vertical: true)
        .padding(G.Space.s12)
        .background(color.opacity(G.Opacity.banner), in: RoundedRectangle(cornerRadius: G.Radius.r8, style: .continuous))
        .overlay {
            if kind == .danger {
                RoundedRectangle(cornerRadius: G.Radius.r8, style: .continuous)
                    .strokeBorder(color.opacity(G.Opacity.bannerEdge), lineWidth: G.Line.hair)
            }
        }
    }

    public init(kind: Kind, title: String, detail: String?, @ViewBuilder actions: @escaping () -> Actions) {
        self.kind = kind
        self.title = title
        self.detail = detail
        self.actions = actions
    }
}

public extension Banner where Actions == EmptyView {
    init(_ kind: Kind, _ title: String, detail: String? = nil) {
        self.init(kind: kind, title: title, detail: detail) { EmptyView() }
    }
}

/// An error with its hint. Product-specific error banners (next steps, details) live in the app.
public struct ErrorBanner: View {
    public let title: String
    public let hint: String?

    public var body: some View { Banner(.danger, title, detail: hint) }

    public init(title: String, hint: String?) {
        self.title = title
        self.hint = hint
    }
}

/// Centred, quiet: an icon, a title, a line or two, and at most one primary action.
public struct EmptyState<Actions: View>: View {
    public let symbol: String
    public let title: String
    public var message: String = ""
    @ViewBuilder public var actions: () -> Actions

    public var body: some View {
        VStack(spacing: G.Space.s8) {
            Image(systemName: symbol).icon(G.Icon.xxl, weight: .light).foregroundStyle(G.text3)
                .padding(.bottom, G.Space.s4)
                .accessibilityHidden(true)
            Text(title).textStyle(.titleS).foregroundStyle(G.text).multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            if !message.isEmpty {
                Text(message).textStyle(.body).foregroundStyle(G.text2)
                    .multilineTextAlignment(.center).frame(maxWidth: G.Width.message)
            }
            actions().padding(.top, G.Space.s8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(G.Space.s40)
    }

    public init(symbol: String, title: String, message: String = "", @ViewBuilder actions: @escaping () -> Actions) {
        self.symbol = symbol
        self.title = title
        self.message = message
        self.actions = actions
    }
}

public extension EmptyState where Actions == EmptyView {
    init(symbol: String, title: String, message: String = "") {
        self.init(symbol: symbol, title: title, message: message) { EmptyView() }
    }
}

/// "Nothing is running." in a section: one quiet line, not a whole empty state.
public struct QuietLine: View {
    public let text: String
    public init(_ text: String) { self.text = text }
    public var body: some View {
        Text(text).textStyle(.body).foregroundStyle(G.text3)
            .frame(maxWidth: .infinity, minHeight: G.Height.row40, alignment: .leading)
    }
}

/// A block of command output, without escape codes or control characters (a server wrote it).
public struct OutputText: View {
    public let text: String
    public var color: Color = G.text
    public var body: some View {
        let shown = DisplayText.clean(text)
        Text(shown.hasSuffix("\n") ? String(shown.dropLast()) : shown)
            .textStyle(.mono)
            .foregroundStyle(color)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(G.Space.s12)
            .surface()
    }

    public init(text: String, color: Color = G.text) {
        self.text = text
        self.color = color
    }
}

/// ProgressBar: a 4-high capsule on `border`, filled with its tone (`accent` while in progress, `ok`
/// when complete or healthy, `warn` when nearly full). The number always sits beside it.
public struct ProgressBar: View {
    /// 0…1.
    public let value: Double
    public var tone: Color = G.accent
    public var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule().fill(G.border)
                Capsule().fill(tone).frame(width: g.size.width * min(max(value, 0), 1))
                    .gAnimation(.progress, value: value)   // motion-progress: never jumps (it does with Reduce Motion)
            }
        }
        .frame(height: G.Line.bar)
        .accessibilityElement()
        .accessibilityValue("\(Int((min(max(value, 0), 1) * 100).rounded())) percent")
    }

    public init(value: Double, tone: Color = G.accent) {
        self.value = value
        self.tone = tone
    }
}

// MARK: Waiting and copying (MotionSpec)

/// When a spinner or skeleton may show (MotionSpec): only after delay-spinner (300 ms) of work, so fast
/// work never flashes one, and once shown for at least hold-spinner (500 ms), so it never flickers.
/// Every spinner gate (DelayedLoading, SpinnerGate, WaitHold) takes its times from here, so they all
/// behave alike. With G.Motion off (debug snapshots) both are zero.
public enum LoadingTiming {
    /// How long work runs before its spinner may show.
    public static var delay: Duration { G.Motion.isOff ? .zero : G.Motion.spinnerDelay }

    /// How much longer something shown for `shownFor` must stay once the work is done.
    public static func holdLeft(shownFor: Duration) -> Duration {
        G.Motion.isOff ? .zero : max(.zero, G.Motion.spinnerHold - shownFor)
    }
}

/// Shows `content` (a spinner, a skeleton) while `isBusy`, by the LoadingTiming rule. With
/// `reservesSpace`, the room it takes stays when it is hidden, so the words beside it never shift.
public struct DelayedLoading<Content: View>: View {
    public let isBusy: Bool
    public var reservesSpace: Bool = false
    @ViewBuilder public var content: () -> Content
    @State private var shown = false
    @State private var shownAt = ContinuousClock.now

    public var body: some View {
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

    public init(isBusy: Bool, reservesSpace: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.isBusy = isBusy
        self.reservesSpace = reservesSpace
        self.content = content
    }
}

/// The small spinner, by the LoadingTiming rule: nothing for 300 ms, then at least 500 ms. Its 16
/// square stays, so the words beside it never move.
public struct DelayedProgress: View {
    public let isBusy: Bool
    public var label: String = "Working"
    public var body: some View {
        DelayedLoading(isBusy: isBusy, reservesSpace: true) {
            ProgressView().controlSize(.small).accessibilityLabel(label)
        }
        .frame(width: G.Icon.md, height: G.Icon.md)
    }

    public init(isBusy: Bool, label: String = "") {
        self.isBusy = isBusy
        self.label = label
    }
}

/// Skeleton: a still `subtle` placeholder for a line of text (12 for caption, 16 for body) or a tile.
/// No shimmer (owner decision 2026-11-15). Put it inside DelayedLoading so a fast load shows nothing.
public struct Skeleton: View {
    public let width: CGFloat
    public var height: CGFloat = G.Space.s12
    public var body: some View {
        RoundedRectangle(cornerRadius: G.Radius.r4, style: .continuous).fill(G.subtle)
            .frame(width: width, height: height)
            .accessibilityHidden(true)
    }

    public init(width: CGFloat, height: CGFloat = G.Space.s12) {
        self.width = width
        self.height = height
    }
}

/// CopyButton: a 24 ghost icon button that copies `text`. Its `square.on.square` is replaced by a
/// `checkmark` in `ok` over motion-fast and comes back after hold-confirm (1.5 s); VoiceOver says
/// "Copied". Copying never happens silently (MotionSpec).
public struct CopyButton: View {
    public let text: String
    public var help: String = "Copy"
    public var size: CGFloat = G.Height.control24
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

    public var body: some View {
        Button {
            Self.copyToPasteboard(text)
            copied = true
            copies += 1
            AccessibilityNotification.Announcement("Copied").post()
        } label: {
            Image(systemName: copied ? "checkmark" : "square.on.square")
                .contentTransition(.symbolEffect(.replace))
                .fontWeight(copied ? .semibold : .regular)
                .foregroundStyle(copied ? G.ok : (hover ? G.text : G.text2))
        }
        .buttonStyle(GhostButtonStyle(square: true, size: size))
        .onHover { hover = $0 }
        .gAnimation(.fast, value: copied)
        .help(copied ? "Copied" : help)
        .accessibilityLabel(copied ? "Copied" : help)
        .task(id: copies) {
            guard copied else { return }
            try? await Task.sleep(for: G.Motion.confirmHold)
            if !Task.isCancelled { copied = false }
        }
    }

    public init(text: String, help: String = "Copy", size: CGFloat = G.Height.control24) {
        self.text = text
        self.help = help
        self.size = size
    }
}

/// A small spinner with what it waits for in a caption ("Reading the tables…"), as ClusterLogsTab draws it.
/// VoiceOver reads the caption, so the wait is never an unnamed spinner. It draws at once: the caller shows it
/// while `.waitHold(_:shown:)` says so, or through ReadingLine (the host tabs), both by the LoadingTiming rule
/// (MotionSpec, delay-spinner and hold-spinner).
public struct ReadingCaption: View {
    public let text: String

    public init(_ text: String) { self.text = text }

    public var body: some View {
        VStack(spacing: G.Space.s8) {
            ProgressView().controlSize(.small).accessibilityHidden(true)
            Text(text).textStyle(.caption).foregroundStyle(G.text3)
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
public enum WaitHold {
    public enum Step: Equatable {
        case show(after: Duration)
        case hide(after: Duration)
    }

    /// What to do next. `shownFor` is how long the wait has been on screen.
    public static func step(isBusy: Bool, shown: Bool, shownFor: Duration) -> Step? {
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

public extension View {
    /// Sets `shown` by the WaitHold rule while `isBusy` comes and goes. Put it on a view that stays on screen
    /// for the whole wait (the list, not the overlay that shows the spinner).
    func waitHold(_ isBusy: Bool, shown: Binding<Bool>) -> some View {
        modifier(WaitHoldModifier(isBusy: isBusy, shown: shown))
    }
}
#endif
