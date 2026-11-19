# Quality review

Where Glamor breaks its own design-system rules, and the fix for each. Nothing is removed: every component stays, used or not. Written 2026-11-19 against main at `3dd35fc45101e44bff46eab58da4bd981553451e`, with antislop, antislop-ui, antislop-human, antislop-copywriting and design-taste-frontend. Every contrast ratio below comes from `antislop-human/contrast-check.py`. A tint drawn at an opacity was first blended over its real ground, then checked.

## Status

The findings below are as written on 2026-11-19. What was done about each fix group:

| Group | Pull request | Status |
|---|---|---|
| 1. Contrast and focus | glamor#12 | Done. Known limit: a `Menu` has no pressed fill, because SwiftUI exposes no pressed state for it and a press opens the menu. `FocusRing` turns the system focus effect off on the menu, so only Glamor's ring draws. |
| 2. Checks that check | glamor#13 | Done. |
| 3. One colour source | glamor (this PR) | Done: every colour and text size comes from design-tokens (v0.2.1, which fixed the palette's own contrast). Mac titles moved from 20, 17 and 15 to 21, 18 and 16. |
| 4. iOS sizes onto tokens | glamor#14, #18 | Done. `.touchTarget()` is deferred until the first iOS control that taps. |
| 5. One vocabulary | glamor#15 | Done. Fonts across platforms are still open (ROADMAP #18). |
| 6. Copy and docs | glamor#16, #17 | Done. `guidelines/journeys.md` and `guidelines/ux-review.md` moved to komando-apps in glamor#17. |

Left as found: the macOS 16 and 24-point click targets (low; they follow the Mac's own sizes) and the disabled primary button's text (exempt in WCAG).

## Counts

| Kind | Where | Count | Severity |
|---|---|---|---|
| Colours and font sizes typed as literals, not read from the vendored tokens | `macOS/Tokens.swift` (32 hex values, 9 font sizes); `GlamorTokens` is read only for the 6 icon sizes (Tokens.swift:267-272) | 41 values | high |
| Vendored tokens and shipped tokens disagree: `GlamorTokens` is a warm sand and brown palette with a brown focus ring (Generated/GlamorTokens.swift:133); `G` is cool grey with a blue accent and a blue ring (Tokens.swift:64-66) | 2 palettes, 1 repo | 1 | high |
| `check-colors.sh` checks nothing in this repo: `ALLOWED='^Sources/Glamor/'` exempts every file it scans (scripts/check-colors.sh:15-16, 25) | 1 script | 1 | high |
| Text under 4.5:1 on the pressed fill `G.Hover.pressed` | `text3` light 4.24:1, dark 4.15:1; `accent` dark 4.48:1 (Tokens.swift:61, 64, 98) | 3 pairs | medium |
| Focusable control with no Glamor focus ring | `MoreMenu` (Lists.swift:296-318), `MenuPicker` (Controls.swift:276-300) | 2 | medium (unsure: macOS may draw its own rectangle, since neither sets `focusEffectDisabled`) |
| Control with hover but no pressed state | `MoreMenu`, `MenuPicker` | 2 | low |
| Literal sizes at call sites (not 0) | `iOS/Surfaces+iOS.swift` (6), `iOS/Feedback+iOS.swift` (6); macOS call sites: 0 | 12 values | medium |
| Two names for one concept | Increase contrast: `increased:` (Tokens.swift:25) vs `high:` (Tokens+iOS.swift:11); tints: `G.Opacity.pill/tint/banner` (Tokens.swift:103-114) vs `G.pillOpacity/tintOpacity/bannerOpacity/edgeOpacity` and `G.Tint` (Tokens+iOS.swift:43-58) | 2 vocabularies | medium |
| One product's content inside the design system | `host`, `target` or `komando` in 9 source files (29 lines); iOS skeleton text "web-1 placeholder", "deploy@10.0.0.4:22" (Feedback+iOS.swift:91-92); 569 mentions of komando in guidelines, components and README | 3 places | medium |
| iOS touch target token unused | `tapMin` 44 (Generated/GlamorTokens.swift:197) is read nowhere; `touch-44` is only a comment (Tokens+iOS.swift:70) | 1 | low (the iOS library has no tappable control yet) Status: `G.touch` added (glamor#14); `.touchTarget()` deferred until the first tappable iOS control. |
| komando content in a Glamor guideline | `guidelines/overview.md`: Editions, Screens, Agent mode and the iPhone and iPad notes (58 komando-specific mentions: targets, KomandoMobile, the sealed file) | 1 file | medium. Status: done. The komando sections are cut; one line points to efolusi/komando-apps design/README.md, which holds a newer copy. Layout rules still name komando's places and stay open. |
| Small Mac click targets | `control16` close mark in a tab, `control24` icon buttons in rows (Tokens.swift:220, 222) | 2 sizes | low |
| Disabled primary button text | `onPrimary` on primary at 30%: light 1.92:1, dark 2.67:1 (Buttons.swift:65-66) | 1 | low (WCAG exempts disabled controls) |
| Tooltip default lost | `MoreMenu.help` defaults to "More" (Lists.swift:300) but `init` passes `""` (Lists.swift:320), so `.help("")` | 1 | low |
| Component folder without a README | `components/Cover/` (58 folders, 57 READMEs) | 1 | low |
| Docs too long to scan | `guidelines/overview.md:23` is one paragraph over 1,200 characters; `guidelines/journeys.md` is 17,146 words | 2 | low |
| Decorative gradient, glass, blur, emoji as icons | none in `Sources/` | 0 | none |
| Em dashes in README, guidelines, component READMEs | none | 0 | none |
| Motion without Reduce Motion | none: every animation goes through `gAnimation` and `gTransition`, which read `accessibilityReduceMotion` (Motion.swift:79, 88; Motion+iOS.swift:23), and `check-motion.sh` passes | 0 | none |

How the counts were made:

- Literal sizes at call sites: `grep -rnE --include='*.swift' '(\.padding\(([^()]*, *)?-?[0-9]+(\.[0-9]+)?\)|spacing: *[0-9]+|(width|height|minHeight|maxWidth|minWidth): *[0-9]+|cornerRadius: *[0-9]+|size: *[0-9]+|opacity\( *[0-9.]+ *\)|(CGFloat|Double) *= *[0-9]+)' Sources/Glamor | grep -v -e Generated -e macOS/Tokens.swift`, then dropped the zeros (`spacing: 0`, `frame(height: 0)`, default `padding: CGFloat = 0`) and the token definitions in `Tokens+iOS.swift`.
- Hex values: `grep -c "0x" Sources/Glamor/macOS/Tokens.swift` (32). Token reads: `grep -c "GlamorTokens\." Sources/Glamor/macOS/Tokens.swift` (6).
- Product words: `grep -rnic "komando\|host\|target" Sources`; `grep -oi komando -r guidelines components README.md | wc -l`.

What `scripts/check-sizes.sh` covers: a literal number written straight into `.system(size:)`, `.padding`, `spacing:`, insets, `cornerRadius:`, frame sizes, grid and column sizes, `rowHeight` and `lineWidth`, and system text styles. It checks only that the number sits on the scale. It misses:

- a literal that is on the scale but should be a token (`.padding(.horizontal, 8)` passes);
- a literal stored first in a property or default argument (`size: CGFloat = 32`, `@ScaledMetric ... = 20`);
- a size made by multiplying (`.font(.system(size: side * 0.5))`, Surfaces+iOS.swift:15);
- offsets, opacities and shadow radii (opacities and shadows are exempt by design).

## The ten worst

1. **Two sources of truth for colour.** `G` types 32 hex values by hand (Tokens.swift:44-82), while the vendored `GlamorTokens` holds a different, warm palette that nothing reads. A token update from design-tokens changes nothing on screen. Fix: map every `G` colour to a `GlamorTokens` pair (or add the missing semantic tokens upstream first), then delete the hex literals from `Tokens.swift`.
2. **The colour check guards nothing here.** `check-colors.sh` exempts `^Sources/Glamor/`, the only folder it scans, so it always passes. Fix: exempt only `macOS/Tokens.swift`, `iOS/Tokens+iOS.swift` and `Generated/`, then fix what it finds.
3. **Brand mismatch.** The README badge is brown `7A4E2B` and the vendored focus ring is brown (GlamorTokens.swift:133); the shipped accent and ring are blue. Fix: the owner picks one brand (decision recorded below the fix PR), then both files follow it.
4. **Secondary text fails on the pressed fill.** `text3` on `G.Hover.pressed` is 4.24:1 light and 4.15:1 dark; `accent` is 4.48:1 dark. The comment at Tokens.swift:84-86 promises 4.5:1 on every hover fill. Fix: lighten `Hover.pressed` (light) and darken it (dark) until all three pairs reach 4.5:1, or darken `text3`, and check again with the script.
5. **Menus without the ring.** `MoreMenu` and `MenuPicker` are the only focusable controls that skip `focusRing`, so a keyboard user sees a different (or no) focus style on them. Fix: add `.focusRing(G.Radius.r6)` (MoreMenu) and the matching radius on `MenuPicker`, plus a `G.Hover.pressed` fill while the menu is open.
6. **Raw sizes in the iOS views.** 12 literals in `Surfaces+iOS.swift` and `Feedback+iOS.swift` (32, 20, 12, 8, 4) skip the tokens; the size check cannot see 4 of them. Fix: move each to `G.Space`, `G.Radius` or a named iOS size, and teach `check-sizes.sh` to flag literal defaults (`CGFloat = n`).
7. **One idea, two names across platforms.** macOS says `increased` and `G.Opacity.pill`; iOS says `high` and `G.pillOpacity`. Fix: rename iOS to the macOS names (`increased:`, `G.Opacity.*`) in one change and update every caller, with no alias.
8. **komando inside the design system.** Hosts, targets and a fake SSH address sit in Glamor's sources and docs, so a second product inherits komando's words. Fix: make the skeleton text a neutral redacted line, move product-only copy and journeys to komando-apps, and keep Glamor's docs product-neutral.
9. **No 44pt rule on iOS.** `tapMin` exists but no view reads it, so the first tappable iOS component has nothing to follow. Fix: add `G.touch = CGFloat(GlamorTokens.Length.tapMin)` in `Tokens+iOS.swift` and a `.touchTarget()` modifier that sets `frame(minWidth:minHeight:)` and `contentShape`.
10. **Docs that cannot be scanned.** One 1,200-character paragraph in `overview.md` and a 17,146-word `journeys.md`; `components/Cover/` has no README. Fix: split overview:23 into a short list, split journeys by journey into their own files, and add `components/Cover/README.md` like its neighbours.

## Order of fixes

Each group is one small PR.

1. **Contrast and focus.** `Sources/Glamor/macOS/Tokens.swift` (the `Hover.pressed` pair and its comment), `Sources/Glamor/macOS/Lists.swift` (`MoreMenu`: focus ring, pressed fill, `help` default), `Sources/Glamor/macOS/Controls.swift` (`MenuPicker`: focus ring, pressed fill).
2. **Checks that check.** `scripts/check-colors.sh` (narrow `ALLOWED` to the token files), `scripts/check-sizes.sh` (flag `CGFloat = n` defaults and `size: x * n`). Fix what they then find in the same PR, or list it for group 4.
3. **One colour source.** `Sources/Glamor/macOS/Tokens.swift` and `Sources/Glamor/iOS/Tokens+iOS.swift` read colours and font sizes from `Sources/Glamor/Generated/GlamorTokens.swift`; the brand decision fixes the `README.md` badge. Needs the owner's brand choice first.
4. **Sizes onto tokens, iOS.** `Sources/Glamor/iOS/Surfaces+iOS.swift` (IconTile 32 and `* 0.5`, StatusDot 8, Pill padding 8 and 4, SeverityMark 20), `Sources/Glamor/iOS/Feedback+iOS.swift` (spacing 8, 12, 4; minHeight 20; tile 32x32), plus the `G.touch` token and `.touchTarget()` in `Tokens+iOS.swift`.
5. **One vocabulary.** `Sources/Glamor/iOS/Tokens+iOS.swift` (`high:` to `increased:`, `G.pillOpacity` and friends to `G.Opacity.*`, `G.Tint` merged into `G.Opacity`) and every caller in `Sources/Glamor/iOS/`.
6. **Copy and docs.** `Sources/Glamor/iOS/Feedback+iOS.swift:91-92` (neutral skeleton text), `guidelines/overview.md` (split line 23), `guidelines/journeys.md` (split, or move komando journeys to komando-apps), `components/Cover/README.md` (new, like its neighbours).
