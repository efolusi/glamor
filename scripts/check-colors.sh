#!/usr/bin/env bash
# Checks that Glamor views take every colour, tint and shadow from the design system
# (guidelines/overview.md › Color roles, States, Shape, borders and depth).
#
# Fails, outside the DesignSystem folders, on:
#   a colour literal          Color(hex:  Color(red:  Color(.sRGB  Color.adaptive(  NSColor(hex:  UIColor(hex:
#   a raw shadow              .shadow(color:  .shadow(radius:      (use .shadow(K.Shadow.x))
#   a raw tint on a token     K.x.opacity(0.3)  MK.x.opacity(0.3)   (use K.Opacity.* / MK.*Opacity)
#   a system colour           .foregroundStyle(.white)  Color.white  .fill(.red) ...
# Showing or hiding with .opacity(x ? 1 : 0) is not a colour and passes.
#
# Usage: scripts/check-colors.sh
set -euo pipefail
cd "$(dirname "$0")/.."
DIRS=(Sources/DesignSystem Sources/DesignSystemMobile)

ALLOWED='/DesignSystem/|/DesignSystemMobile/'

PATTERN='Color\(hex:|Color\(red:|Color\(\.sRGB|Color\.adaptive\(|NSColor\(hex:|UIColor\(hex:'
PATTERN+='|\.shadow\(color:|\.shadow\(radius:'
PATTERN+='|\bM?K\.[A-Za-z.]+\.opacity\([0-9.]+\)'
PATTERN+='|(foregroundStyle|fill|background|tint|stroke|strokeBorder)\(\.(white|black|red|green|blue|orange|yellow|gray|purple|pink|mint|teal|cyan|indigo|brown)\b'
PATTERN+='|\bColor\.(white|black|red|green|blue|orange|yellow|gray|purple|pink|mint|teal|cyan|indigo|brown)\b'

found=$({ grep -rnE --include='*.swift' -- "$PATTERN" "${DIRS[@]}" || true; } | grep -vE "$ALLOWED" || true)
if [ -n "$found" ]; then
    echo "$found"
    echo "Colour outside the tokens: use K / MK colours, K.Opacity, K.Hover and .shadow(K.Shadow.x) from DesignSystem." >&2
    exit 1
fi
echo "Colors: every colour, tint and shadow comes from the design system."
