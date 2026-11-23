#if os(iOS)
import SwiftUI
import UIKit

/// A change or a check the person started did not happen: an icon and the words, in danger, where they
/// acted. VoiceOver hears it once, when it happens: the screen says it with `resultFeedback` or
/// `announcesFailure`, not this row, which appears again each time it scrolls back into view.
public struct FailureLine: View {
    public let text: String
    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: G.Space.labelIcon) {
            Image(systemName: "xmark.circle.fill").accessibilityHidden(true)
            Text(DisplayText.clean(text))
        }
        .font(G.small).foregroundStyle(G.danger)
        .fixedSize(horizontal: false, vertical: true)
    }

    public init(text: String) {
        self.text = text
    }
}

/// A loading row that shows only after 300 ms, so a quick answer never flashes one (owner's motion
/// decision, 2026-11-15). Static: the system spinner and the words, no shimmer.
public struct DelayedProgress: View {
    public let text: String
    @State private var shown = false
    public var body: some View {
        HStack(spacing: G.Space.s8) {
            if shown {
                ProgressView()
                Text(text).foregroundStyle(G.text3)
            }
        }
        .frame(minHeight: G.Height.row20)
        .accessibilityElement(children: .combine)
        .task {
            try? await Task.sleep(for: PhoneMotion.loadingDelay)
            shown = true
        }
    }

    public init(text: String) {
        self.text = text
    }
}

/// A small spinner at the end of a button's row (Refresh, Verify the Record): nothing for 300 ms, then at
/// least 500 ms, so a quick answer never flashes it. Its place is kept, so the label never moves.
public struct DelayedSpinner: View {
    public let isBusy: Bool
    @State private var shown = false
    @State private var shownAt = ContinuousClock.now
    public var body: some View {
        ProgressView()
            .opacity(shown ? 1 : 0)
            .accessibilityHidden(!shown)
            .task(id: isBusy) {
                if isBusy {
                    guard !shown else { return }
                    try? await Task.sleep(for: PhoneMotion.loadingDelay)
                    if Task.isCancelled { return }
                    shownAt = .now
                    shown = true
                } else if shown {
                    try? await Task.sleep(for: PhoneMotion.holdLeft(shownFor: shownAt.duration(to: .now)))
                    if Task.isCancelled { return }
                    shown = false
                }
            }
    }

    public init(isBusy: Bool) {
        self.isBusy = isBusy
    }
}

/// The skeleton of a list that has not answered yet: placeholder rows in the shape of the real ones,
/// static and shown after 300 ms. VoiceOver hears the words instead.
public struct ListSkeleton: View {
    public let text: String
    public var rows: Int = 4
    @State private var shown = false
    public var body: some View {
        List {
            if shown {
                Section {
                    ForEach(0..<rows, id: \.self) { _ in
                        HStack(spacing: G.Space.s12) {
                            RoundedRectangle(cornerRadius: G.Radius.r8).fill(G.subtle).frame(width: G.Tile.t32, height: G.Tile.t32)
                            VStack(alignment: .leading, spacing: G.Space.s4) {
                                Text("Loading item name").font(G.bodyStrong)
                                Text("Loading detail line").font(G.monoSmall)
                            }
                            .redacted(reason: .placeholder)
                        }
                    }
                } header: { Text(text).textCase(nil) }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
        .task {
            try? await Task.sleep(for: PhoneMotion.loadingDelay)
            shown = true
        }
    }

    public init(text: String, rows: Int = 4) {
        self.text = text
        self.rows = rows
    }
}

/// A Copy button's answer: "Copied" for hold-confirm (1.5 s, as on the Mac), said to VoiceOver, with the success haptic.
@MainActor func announceCopied(_ copied: Binding<Bool>) {
    copied.wrappedValue = true
    saidCopied()
    Task {
        try? await Task.sleep(for: PhoneMotion.confirmHold)
        copied.wrappedValue = false
    }
}

/// A Copy in a menu or a swipe, which has no button to say "Copied" on: the text goes to the
/// pasteboard, VoiceOver hears "Copied" and the success haptic plays.
@MainActor func copyAndSay(_ text: String) {
    UIPasteboard.general.string = text
    saidCopied()
}

@MainActor private func saidCopied() {
    AccessibilityNotification.Announcement("Copied").post()
    UINotificationFeedbackGenerator().notificationOccurred(.success)
}

public extension View {
    /// The iPhone's answer to a result the person started (owner's motion decision): the success haptic
    /// each time `done` goes up; the error haptic and VoiceOver hearing `failure` each time `failed`
    /// goes up, also when the same failure happens twice. The system leaves the haptics out when the
    /// person turned System Haptics off.
    func resultFeedback(done: Int, failed: Int, failure: String?) -> some View {
        sensoryFeedback(.success, trigger: done)
            .sensoryFeedback(.error, trigger: failed)
            .onChange(of: failed) { _, _ in
                if let failure { AccessibilityNotification.Announcement(DisplayText.clean(failure)).post() }
            }
    }

    /// VoiceOver hears a read's failure when it happens, not each time its row scrolls back into view.
    func announcesFailure(_ text: String?) -> some View {
        onChange(of: text) { _, now in
            if let now { AccessibilityNotification.Announcement(DisplayText.clean(now)).post() }
        }
    }
}
#endif
