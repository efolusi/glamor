import SwiftUI

/// The mark of a paid feature (`pro`) or of one that is not built yet (`soon`), drawn by `Pill(mark:)` (GL36).
/// A mark sits inside a page next to the thing it names (Settings Sync, Team, AI, Approvals), never on a row of a
/// list of places. The WORD carries the meaning (Pro, Soon), never the colour and never the outline: the Soon
/// outline is the border colour at 1.10 to 1.40:1 on its grounds, so the dashed edge is close to invisible and is
/// decoration only. VoiceOver says what the mark means ("Pro, paid feature"), not only its word.
public enum PlanMark: Sendable, CaseIterable {
    case pro, soon

    /// The word on the mark, in `language` (nil: the host app's, then the person's list).
    func word(language: String? = nil) -> String {
        switch self {
        case .pro: GlamorText.string(.markPro, language: language)
        case .soon: GlamorText.string(.markSoon, language: language)
        }
    }

    /// What VoiceOver says for the mark.
    func spoken(language: String? = nil) -> String {
        switch self {
        case .pro: GlamorText.string(.markProSpoken, language: language)
        case .soon: GlamorText.string(.markSoonSpoken, language: language)
        }
    }

    /// The word's colour: the brand's brown for Pro, `text2` for Soon. Both are 4.5:1 or more on every ground a mark
    /// sits on (ContrastTests).
    var label: Color {
        switch self {
        case .pro: G.accentFg
        case .soon: G.text2
        }
    }

    /// The outline's colour: `accentEdge` (3:1 as a shape) for Pro. The border colour for Soon: 1.10 to 1.40:1,
    /// a quiet frame that nobody has to see, because the word says Soon.
    var edge: Color {
        switch self {
        case .pro: G.accentEdge
        case .soon: G.border
        }
    }

    /// The outline's dash: none for Pro; as the page's `DashedDivider` for Soon (decoration, see `edge`).
    var dash: [CGFloat] {
        switch self {
        case .pro: []
        case .soon: [G.Space.s4, G.Space.s4]
        }
    }
}
