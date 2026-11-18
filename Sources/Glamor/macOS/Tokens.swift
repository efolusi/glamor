#if os(macOS)
import AppKit
import SwiftUI

// The design system's tokens: colors (light and dark) and every size on the 4-point scale.
// Views use only these names (G.*), never a literal color or size; scripts/check-sizes.sh enforces it.

// MARK: Palette: light and dark, following the system (or the person's choice)

public extension NSColor {
    convenience init(hex: UInt32) {
        self.init(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
    }
}

public extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255, opacity: opacity)
    }

    /// One colour for light appearance, one for dark, and optionally a stronger pair for
    /// System Settings › Accessibility › Display › Increase contrast.
    static func adaptive(_ light: UInt32, _ dark: UInt32, increased: (light: UInt32, dark: UInt32)? = nil) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let match = appearance.bestMatch(from: [.aqua, .darkAqua, .accessibilityHighContrastAqua,
                                                    .accessibilityHighContrastDarkAqua])
            let isDark = match == .darkAqua || match == .accessibilityHighContrastDarkAqua
            // SwiftUI resolves a colour with its own appearance, which can drop the high-contrast name,
            // so the system setting itself is read too.
            let isHigh = match == .accessibilityHighContrastAqua || match == .accessibilityHighContrastDarkAqua
                || NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast || IncreasedContrast.forced
            if isHigh, let increased { return NSColor(hex: isDark ? increased.dark : increased.light) }
            return NSColor(hex: isDark ? dark : light)
        })
    }
}

/// Debug snapshots only: draw the Increase contrast colours without changing the person's settings.
public enum IncreasedContrast { nonisolated(unsafe) static var forced = false }

public enum G {
    public static let window = Color.adaptive(0xF3F3F1, 0x0F1115)     // behind everything, and the sidebar
    public static let panel = Color.adaptive(0xFFFFFF, 0x17191F)      // the content panel
    public static let card = Color.adaptive(0xFFFFFF, 0x1D2028)
    public static let cardHover = Color.adaptive(0xF7F7F5, 0x242833)
    public static let subtle = Color.adaptive(0xF4F4F2, 0x20232C)     // code, chips, selected rows
    public static let field = Color.adaptive(0xFFFFFF, 0x14161C)
    /// Decorative hairlines only. With Increase contrast they take controlEdge, so cards and secondary
    /// buttons keep a 3:1 edge.
    public static let border = Color.adaptive(0xE4E4E1, 0x2A2E39, increased: (0x8C8C91, 0x6D717D))
    /// border's colour used as a fill (a pressed ghost button, the tab ×'s hover, an underline tab's hover
    /// bar). It does not darken with Increase contrast as the hairline does, so a glyph on it keeps 4.5:1.
    public static let borderFill = Color.adaptive(0xE4E4E1, 0x2A2E39)
    /// The outline of a control: an off switch track, an unchecked checkbox, a text field.
    /// 3:1 or more on window, panel, card, cardHover, subtle and field in both themes.
    public static let controlEdge = Color.adaptive(0x8C8C91, 0x6D717D)
    public static let text = Color.adaptive(0x1C1C1E, 0xECEDF1)
    public static let text2 = Color.adaptive(0x505056, 0xB3B7C4)
    public static let text3 = Color.adaptive(0x6E6E75, 0x8A8E9C, increased: (0x505056, 0xB3B7C4))   // text2 with Increase contrast
    /// The status colors take a darker (light) or lighter (dark) pair with Increase contrast, so their
    /// text holds 4.6:1 or more inside a pill at the 16% tint (design/tokens.json lists every ratio).
    public static let accent = Color.adaptive(0x1659FF, 0x6090FF, increased: (0x074EFF, 0x6F9BFF))
    /// The keyboard focus ring (focus): 4.8:1 or more against what surrounds it, both themes.
    public static let focus = accent
    /// The one mark of a chosen item (selected-marker), so selection never rests on a fill alone.
    public static let selectedMarker = accent
    /// A glyph or word on an accent fill (the agent's send button): 5.4:1 in light, 6.2:1 in dark.
    public static let onAccent = Color.adaptive(0xFFFFFF, 0x111216)
    public static let primary = Color.adaptive(0x1C1C1E, 0xECEDF1)    // the black (white) main button
    /// The main button under the pointer and pressed: opaque mixes toward onPrimary, so the ground never shows
    /// through. onPrimary on them: 11.9 / 12.5:1 and 9.0 / 10.4:1.
    public static let primaryHover = Color.adaptive(0x373739, 0xD2D3D7)
    public static let primaryPressed = Color.adaptive(0x49494B, 0xC0C1C5)
    public static let onPrimary = Color.adaptive(0xFFFFFF, 0x111216)
    public static let ok = Color.adaptive(0x247A43, 0x45C46A, increased: (0x227440, 0x45C46A))
    public static let warn = Color.adaptive(0xB24A00, 0xF2A445, increased: (0xA84600, 0xF2A445))
    public static let danger = Color.adaptive(0xCA282E, 0xF36368, increased: (0xBD252B, 0xF47478))
    public static let scrim = Color.black.opacity(0.18)                     // behind sheets, alerts and ⌘K
    /// The avatar's one solid fill, the same in both themes, so the white initial holds 5.3:1.
    public static let avatar = Color(hex: 0x247A43)
    public static let onAvatar = Color(hex: 0xFFFFFF)

    /// What sits under an item while the pointer is on it (design system: hover-*). One fill per ground, so
    /// every hover is about as visible as every other in both themes (1.06 to 1.12:1) and text3 keeps 4.5:1
    /// on it. A raised control (secondary button, HoverCard) uses cardHover instead; nothing hovers in accent.
    public enum Hover {
        /// A list row, table row, ⋯ or ghost button inside a card.
        public static let onCard = Color.adaptive(0xF4F4F2, 0x242833, increased: (0xE8E8E6, 0x2E323C))
        /// A menu, palette or side-list row, a tab, a chip or a ghost button on the panel.
        public static let onPanel = Color.adaptive(0xF4F4F2, 0x20232C, increased: (0xE8E8E6, 0x2A2E39))
        /// A panel-header tab under the pointer: quieter than the active tab's subtle, 1.06:1 on panel.
        public static let onTab = Color.adaptive(0xF8F8F7, 0x1C1F27, increased: (0xEDEDEB, 0x252831))
        /// A sidebar place or the More row, on the window.
        public static let onWindow = Color.adaptive(0xFAFAF9, 0x16181D, increased: (0xE8E8E6, 0x202329))
        /// Any item or raised control while the mouse is down. Nothing fades on press.
        public static let pressed = Color.adaptive(0xEBEBE9, 0x2A2E39, increased: (0xDEDEDC, 0x363A45))
    }

    /// How strongly a tint shows behind its glyph or word. Pills sit lower than tiles so every
    /// status color keeps 4.6:1 or more on its pill in both themes (accent 4.63:1 in light is the lowest).
    public enum Opacity {
        public static let tint: Double = 0.12  // icon tiles
        public static let pill: Double = 0.10  // status pills and the Protected capsule, over an opaque card
        /// Pills and tiles with Increase contrast (design/README.md), so the shape stands out from the card.
        public static let increased: Double = 0.16
        /// accent behind a chosen row, always with the selected marker.
        public static let selected: Double = 0.10
        /// A banner's fill and a diff line's tint; its border.
        public static let banner: Double = 0.10
        public static let bannerEdge: Double = 0.25
        /// An attention or approval card's fill and border (the border matches a banner's).
        public static let attention: Double = 0.05
        public static let attentionEdge: Double = 0.25
        /// accent at 70%: a focused field's outline.
        public static let ring: Double = 0.7
        /// onPrimary behind the shortcut badge in a primary button.
        public static let kbd: Double = 0.18
        /// border at 70%: separators inside a CardList or table, an output pane's frame.
        public static let softHairline: Double = 0.7
        /// card under an unchosen chip.
        public static let chip: Double = 0.6
        /// The primary button when disabled.
        public static let disabled: Double = 0.3

        /// The tile tint for this contrast: read `@Environment(\.colorSchemeContrast)` in the view.
        public static func tint(_ contrast: ColorSchemeContrast) -> Double { isIncreased(contrast) ? increased : tint }
        /// The pill tint for this contrast.
        public static func pill(_ contrast: ColorSchemeContrast) -> Double { isIncreased(contrast) ? increased : pill }

        /// The environment, or a debug snapshot that forces Increase contrast (as Color.adaptive reads it).
        private static func isIncreased(_ contrast: ColorSchemeContrast) -> Bool {
            contrast == .increased || IncreasedContrast.forced
        }
    }

    /// The only shadows, at rest or on hover. Draw them with `.shadow(G.Shadow.x)` (scripts/check-colors.sh).
    public struct ShadowStyle {
        public let color: Color
        public let radius: CGFloat
        public let y: CGFloat

        public init(color: Color, radius: CGFloat, y: CGFloat) {
            self.color = color
            self.radius = radius
            self.y = y
        }
    }

    public enum Shadow {
        /// Raised controls at rest: primary and secondary buttons, MenuPicker, the chosen segment, the split tip.
        public static let control = ShadowStyle(color: .black.opacity(0.06), radius: 1, y: 1)
        /// The floating content panel: just enough to lift it off the window.
        public static let panel = ShadowStyle(color: .black.opacity(0.04), radius: 12, y: 2)
        /// The command palette: it floats above everything, so it casts the deepest shadow.
        public static let palette = ShadowStyle(color: .black.opacity(0.18), radius: 32, y: 12)
        /// A HoverCard under the pointer: it shows the card can be clicked.
        public static let hover = ShadowStyle(color: .black.opacity(0.06), radius: 8, y: 2)
        /// No shadow: for a shadow that comes and goes with a state (`hover ? .hover : .none`).
        public static let none = ShadowStyle(color: .clear, radius: 0, y: 0)
    }

    // MARK: Sizes: everything sits on a 4-point grid

    /// Six sizes (11, 12, 13, 15, 17, 20) in three weights. No half sizes and no system text styles.
    public enum Font {
        public static let titleL = SwiftUI.Font.system(size: 20, weight: .semibold)      // form and sheet titles
        public static let titleM = SwiftUI.Font.system(size: 17, weight: .semibold)      // the panel title, a target's name
        public static let titleS = SwiftUI.Font.system(size: 15, weight: .semibold)      // section and empty-state titles
        public static let bodyStrong = SwiftUI.Font.system(size: 13, weight: .semibold)  // the primary button and headings inside a panel (titles are semibold; names and labels are bodyMedium)
        public static let bodyMedium = SwiftUI.Font.system(size: 13, weight: .medium)    // field labels, the secondary button
        public static let body = SwiftUI.Font.system(size: 13)
        public static let caption = SwiftUI.Font.system(size: 12)                        // help, subtitles, metadata
        public static let small = SwiftUI.Font.system(size: 11, weight: .medium)         // pills, shortcut badges
        public static let sectionLabel = SwiftUI.Font.system(size: 11, weight: .semibold) // GROUPS, with `sectionTracking`
        public static let sectionTracking: CGFloat = 0.6
        public static let inputL = SwiftUI.Font.system(size: 17)                         // the command palette's field
        public static let monoL = SwiftUI.Font.system(size: 13, design: .monospaced)     // the command bar, mono fields
        public static let mono = SwiftUI.Font.system(size: 12, design: .monospaced)      // output, commands on cards
        public static let monoS = SwiftUI.Font.system(size: 11, design: .monospaced)     // ratios, fingerprints

        /// Body text that turns semibold when its row or tab is selected.
    }

    public static let mono = Font.mono
    public static let monoLarge = Font.monoL

    /// Paddings, gaps and insets. 2 is only for the gap between stacked lines of text.
    public enum Space {
        public static let s2: CGFloat = 2
        public static let s4: CGFloat = 4
        public static let s8: CGFloat = 8
        public static let s12: CGFloat = 12
        public static let s16: CGFloat = 16
        public static let s20: CGFloat = 20
        public static let s24: CGFloat = 24
        public static let s32: CGFloat = 32
        public static let s40: CGFloat = 40
        public static let s48: CGFloat = 48
    }

    /// Corner radii, chosen by the height of the thing. Pills, dots and bars are capsules.
    public enum Radius {
        public static let r4: CGFloat = 4      // shortcut badges
        public static let r6: CGFloat = 6      // compact controls (28)
        public static let r8: CGFloat = 8      // standard controls (32), rows, tabs, banners, output
        public static let r12: CGFloat = 12    // cards, the panel, the search and command bars
        public static let r16: CGFloat = 16    // the command palette, sheets
        public static let tile: CGFloat = 0.25 // icon tiles and the logo: a quarter of the side
    }

    public static let radius = Radius.r12

    /// Fixed heights. Fixed-height things set their height and centre their content.
    public enum Height {
        public static let line16: CGFloat = 16      // a line of 11 to 13 point text
        public static let line20: CGFloat = 20      // a line of title-s
        public static let line24: CGFloat = 24      // a line of title-m, title-l and input-l
        public static let control16: CGFloat = 16   // shortcut badges, the close button in a tab
        public static let pill: CGFloat = 20
        public static let control24: CGFloat = 24   // icon-only buttons inside rows
        public static let control28: CGFloat = 28   // compact: toolbars, cards, table rows, chips
        public static let control32: CGFloat = 32   // standard: every button and field on a page or in a form
        public static let control40: CGFloat = 40   // the search bar and the command bar line
        public static let row32: CGFloat = 32       // sidebar places, list and table rows, menu items
        public static let row40: CGFloat = 40       // palette, info, inventory, group rows, activity lines
        public static let row52: CGFloat = 52       // two-line rows
        public static let row64: CGFloat = 64       // three-line rows
        public static let tab: CGFloat = 28         // a tab in the panel header
        public static let paneHead: CGFloat = 28
        public static let statusBar: CGFloat = 28
        public static let tableHeader: CGFloat = 28
        public static let toolbar: CGFloat = 44
        public static let header: CGFloat = 52      // the panel header, its rule included
        public static let paletteField: CGFloat = 56 // the command palette's field
        public static let trafficLights: CGFloat = 40
        public static let windowMin: CGFloat = 680     // the main window's minimum, so the sidebar and a page both fit
        public static let outputSheet: CGFloat = 440   // a run's output sheet: about 24 lines of output
        public static let windowDefault: CGFloat = 840 // the main window's first size: a page and the agent drawer fit
        public static let emptyStateMin: CGFloat = 360  // an empty page (Hosts, Connections, Port Forwarding) keeps its empty state from collapsing
        public static let outputMax: CGFloat = 420      // a check's output pane on a page: about 24 lines, then it scrolls
        public static let settings: CGFloat = 600       // the Settings window: its tallest tab fits without scrolling
    }

    /// Icon tiles come in five sizes, each with a fixed glyph.
    public enum Tile {
        public static let t20: CGFloat = 20
        public static let t28: CGFloat = 28
        public static let t32: CGFloat = 32
        public static let t40: CGFloat = 40
        public static let t48: CGFloat = 48

        /// The glyph box for a tile: 20 → 12, 28 and 32 → 16, 40 → 20, 48 → 24.
        public static func glyph(_ tile: CGFloat) -> CGFloat {
            switch tile {
            case ...t20: Icon.i12
            case ...t32: Icon.i16
            case ...t40: Icon.i20
            default: Icon.i24
            }
        }
    }

    /// SF Symbols on the icon scale. Each size is the box the glyph fills.
    public enum Icon {
        public static let i8: CGFloat = 8      // the close mark in a tab or chip
        public static let i12: CGFloat = 12    // chevrons, locks, icons in compact buttons
        public static let i16: CGFloat = 16    // sidebar places, row icons, toolbar icons
        public static let i20: CGFloat = 20    // the run button, glyphs in 40 tiles
        public static let i24: CGFloat = 24    // glyphs in 48 tiles
        public static let i32: CGFloat = 32    // empty states

        /// The point size that makes a symbol fill a box of `box` points: a symbol draws about a
        /// fifth larger than its point size, so a 16 box takes a 12.8 point symbol (the body's size).
        public static func point(_ box: CGFloat) -> CGFloat { box * 0.8 }
    }

    public enum Dot {
        public static let d6: CGFloat = 6      // inside small text: the sidebar status line, pane heads
        public static let d8: CGFloat = 8      // every other status dot
    }

    public enum Line {
        public static let hair: CGFloat = 1    // hairlines and borders
        public static let strong: CGFloat = 2  // the selected underline tab, the focus ring, the selected marker
        public static let focusOffset: CGFloat = 2  // focus-offset: the gap between a control and its focus ring
        public static let bar: CGFloat = 4     // progress bars
    }

    public enum Width {
        public static let splitListMin: CGFloat = 232     // a split's list (schema, cache keys) never gets narrower than a name and its count
        public static let splitDetailMin: CGFloat = 420   // a split's detail never gets narrower than about 50 mono characters
        public static let sidebar: CGFloat = 256
        public static let pageMax: CGFloat = 1280
        public static let form: CGFloat = 640
        public static let addPage: CGFloat = 896   // the Add page: four kind cards and the importers (PageAdd)
        public static let stats: CGFloat = 300
        public static let inspector: CGFloat = 340
        public static let sidePanel: CGFloat = 272
        public static let chat: CGFloat = 760
        public static let palette: CGFloat = 620
        public static let menu: CGFloat = 320
        public static let profileMenu: CGFloat = 260
        public static let sheet: CGFloat = 520
        public static let message: CGFloat = 440   // an empty state's message
        public static let settings: CGFloat = 640  // the Settings window, by G.Height.settings
        public static let detail: CGFloat = 760    // a target's Overview
        public static let time: CGFloat = 112      // a relative time at the end of a row
        public static let hostName: CGFloat = 304  // the name column on Hosts (grows for a longer name)
        public static let connName: CGFloat = 296  // the name column on Connections
        public static let secretName: CGFloat = 240
        public static let jobLog: CGFloat = 400    // the log beside the jobs
        public static let cacheKeys: CGFloat = 340
        public static let state: CGFloat = 72      // a job's state word
        public static let gutter: CGFloat = 48     // line numbers beside SQL
        public static let agent: CGFloat = 400     // the agent drawer
        public static let windowMin: CGFloat = 1040   // the main window's minimum: sidebar, panel and a 760 page
        public static let outputSheet: CGFloat = 680  // a run's output sheet: about 90 characters of mono output
        public static let windowDefault: CGFloat = 1320  // the main window's first size: sidebar, panel and a wide page
        public static let cardMin: CGFloat = 248      // a card in a card grid never gets narrower than this
        public static let cardMax: CGFloat = 420      // nor wider, so a wide window adds columns instead
        public static let forwardName: CGFloat = 280   // a forward's address and target column, so rows line up
        public static let forwardKind: CGFloat = 112   // a forward's kind column, as wide as a relative time
        public static let numberField: CGFloat = 112  // a Port or DB number field: five digits and room for its placeholder
        public static let updateKind: CGFloat = 88    // the Kind column on a host's Updates tab: a Security pill
    }

    /// One area a SplitDivider sizes: its settings key, its smallest width (or height), its default and its
    /// largest. A nil default is half the room (the Files panes, the query, cache and terminal splits; `defaultSize(room:)`); a nil largest has no
    /// limit but the room there is (the page passes that in).
    public struct ResizeArea: Equatable, Sendable {
        public let key: String
        public let min: CGFloat
        public let ideal: CGFloat?
        public let max: CGFloat?

        /// The range a divider keeps to when `room` is free for this area; never smaller than `min`.
        public func range(room: CGFloat = .infinity) -> ClosedRange<CGFloat> {
            min...Swift.max(min, Swift.min(max ?? room, room))
        }

        public init(key: String, min: CGFloat, ideal: CGFloat?, max: CGFloat?) {
            self.key = key
            self.min = min
            self.ideal = ideal
            self.max = max
        }
    }

    /// The resizable areas and their widths (SplitDivider card, owner decision 2026-11-14). Every number is
    /// on the 4-pt scale and every width is saved app-wide under its key.
    public enum Resize {
        public static let step: CGFloat = 4       // a drag snaps to it; ← → move a divider by it
        public static let bigStep: CGFloat = 32   // ⇧← ⇧→
        public static let hitArea: CGFloat = 4    // centred on the hairline, 2 each side
        public static let gripLength: CGFloat = 24
        public static let gripThickness: CGFloat = 4

        public static let sidebar = ResizeArea(key: "sidebar", min: 200, ideal: 256, max: 320)   // under 200 it hides
        public static let agent = ResizeArea(key: "agent", min: 320, ideal: 400, max: 560)
        public static let recipes = ResizeArea(key: "recipes", min: 224, ideal: 272, max: 400)
        public static let jobs = ResizeArea(key: "jobs", min: 320, ideal: 400, max: 640)
        public static let audit = ResizeArea(key: "audit", min: 280, ideal: 340, max: 480)
        public static let filesPane = ResizeArea(key: "files.pane", min: 320, ideal: nil, max: nil)
        public static let filesTransfers = ResizeArea(key: "files.transfers", min: 96, ideal: 160, max: nil)  // largest: half the page
        public static let querySplit = ResizeArea(key: "query.split", min: 240, ideal: nil, max: nil)
        public static let cacheSplit = ResizeArea(key: "cache.split", min: 240, ideal: nil, max: nil)
        public static let terminalSplit = ResizeArea(key: "terminal.split", min: 240, ideal: nil, max: nil)

        /// A table column's edge drags between these (DataTable card); its width is saved per table.
        public static let columnMin: CGFloat = 64
        public static let columnMax: CGFloat = 640

        /// The Edit File sheet: 520 by up to 480 when it opens, never under 520 by 320; it grows to the screen.
        public static let editSheetMin = CGSize(width: G.Width.sheet, height: 320)
        public static let editSheetIdeal = CGSize(width: G.Width.sheet, height: 480)
        /// The Settings window: 640 by 600 when it opens and no smaller; it grows to the screen.
        public static let settingsWindow = CGSize(width: G.Width.settings, height: G.Height.settings)

        /// The main window's least width beside a sidebar of `sidebar` (0 when hidden): the 760 page
        /// minimum plus the insets. With the 256 default this is the old fixed 1040 (`G.Width.windowMin`).
        public static let pageMin: CGFloat = 760
        public static let windowInsets: CGFloat = 24
        public static func windowMin(sidebar: CGFloat) -> CGFloat { sidebar + pageMin + windowInsets }

        /// Every area, so a test can check that the keys differ and the numbers sit on the scale.
        public static let areas = [sidebar, agent, recipes, jobs, audit, filesPane, filesTransfers, querySplit, cacheSplit,
                            terminalSplit]
    }




    /// A selectable row in a list (design system: ListRow). The highlight never touches the list's edge
    /// and never runs into the next row, and the text sits at the same place at rest, under the pointer and
    /// selected, like a macOS source list.
    public enum Row {
        /// From a side list's edge (Recipes, the schema, cache keys) to the row's highlight.
        public static let listInset: CGFloat = Space.s8
        /// From a card's edge to the row's highlight, on every side: the card's 12 radius less 4 is the
        /// highlight's 8, so the corners stay concentric.
        public static let cardInset: CGFloat = Space.s4
        /// From the highlight's edge to the row's first glyph.
        public static let padding: CGFloat = Space.s12
        /// Between two rows of a side list.
        public static let gap: CGFloat = Space.s2
        /// The highlight's corners.
        public static let radius: CGFloat = Radius.r8
        /// A one-line row (name, maybe a count) and a two-line row (a name over one line of help).
        public static let oneLine: CGFloat = Height.row32
        public static let twoLine: CGFloat = Height.row52
    }

    public enum Inset {
        public static let window: CGFloat = 8      // around the floating panel
        public static let paletteTop: CGFloat = 88
        /// AppKit's line fragment padding: where typed text starts inside a TextEditor.
        public static let textEditor: CGFloat = 5
    }
}

public extension View {
    /// Draws one of the G.Shadow tokens: `.shadow(G.Shadow.panel)`.
    func shadow(_ style: G.ShadowStyle) -> some View {
        shadow(color: style.color, radius: style.radius, y: style.y)
    }
}
#endif
