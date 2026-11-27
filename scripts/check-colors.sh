#!/usr/bin/env bash
# Checks that Glamor views take every colour, tint and shadow from the design system
# (guidelines/overview.md › Color roles, States, Shape, borders and depth).
#
# Fails, outside Glamor's token files, on:
#   a colour literal          Color(hex:  Color(red:  Color(.sRGB  Color.adaptive(  NSColor(hex:  UIColor(hex:
#   a raw shadow              .shadow(color:  .shadow(radius:      (use .shadow(G.Shadow.x))
#   a raw tint on a token     G.x.opacity(0.3)   (use G.Opacity.* on Mac, G.*Opacity on iOS)
#   a system colour           .foregroundStyle(.white)  Color.white  .fill(.red) ...
#   the accent as a shape     .fill(G.accent)  .strokeBorder(G.accentHover)  tone: Color = G.accent
#                             (copper is 2.1 to 2.7:1 on a light ground: use G.accentEdge; the main button's fill
#                             and a glass tint stay G.accent and carry the accentEdge rim)
#   accent.warm, accent.soft  accentWarm  accentSoft  (2.89 and 1.83:1: text or decoration only, never a control's edge)
# Showing or hiding with .opacity(x ? 1 : 0) is not a colour and passes.
#
# Usage: scripts/check-colors.sh
set -euo pipefail
cd "$(dirname "$0")/.."
DIRS=(Sources/Glamor)

ALLOWED='^Sources/Glamor/(macOS/Tokens\.swift|iOS/Tokens\+iOS\.swift|Generated/)'

PATTERN='Color\(hex:|Color\(red:|Color\(\.sRGB|Color\.adaptive\(|NSColor\(hex:|UIColor\(hex:'
PATTERN+='|\.shadow\(color:|\.shadow\(radius:'
PATTERN+='|\bG\.[A-Za-z.]+\.opacity\([0-9.]+\)'
PATTERN+='|(foregroundStyle|fill|background|tint|stroke|strokeBorder)\(\.(white|black|red|green|blue|orange|yellow|gray|purple|pink|mint|teal|cyan|indigo|brown)\b'
PATTERN+='|\b(fill|stroke|strokeBorder)\(G\.accent(Hover|Pressed)?[,)]'
PATTERN+='|\btone[A-Za-z]*: Color = G\.accent([^A-Za-z]|$)'
PATTERN+='|\baccent(Warm|Soft)\b'
PATTERN+='|\bColor\.(white|black|red|green|blue|orange|yellow|gray|purple|pink|mint|teal|cyan|indigo|brown)\b'

found=$({ grep -rnE --include='*.swift' -- "$PATTERN" "${DIRS[@]}" || true; } | grep -vE "$ALLOWED" || true)
if [ -n "$found" ]; then
    echo "$found"
    echo "Colour outside the tokens: use G colours, G.Opacity, G.Hover and .shadow(G.Shadow.x) from Glamor. A shape drawn with the accent uses G.accentEdge." >&2
    exit 1
fi
echo "Colors: every colour, tint and shadow comes from the design system."
