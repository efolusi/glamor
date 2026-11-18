#!/usr/bin/env bash
# Checks that every size in Glamor Swift sources sits on the design system's scale.
#
# Prints each numeric font size, padding, spacing, corner radius, frame width or height
# (and a few relatives: line widths, grid sizes, table row heights) that is off the scale,
# and exits 1 if it finds any. Opacities and shadow radii are exempt.
#
#   fonts            11 12 13 15 17 20, and no system text styles (.caption, .title2 ...)
#   padding/spacing  0 1 2 4 8 12 16 20 24 32 40 48
#   corner radii     4 6 8 12 16, or a quarter of a side (size * 0.25)
#   widths/heights   multiples of 4, or 1 and 2 (hairlines, strong lines)
#   line widths      1 2
#
# Usage: scripts/check-sizes.sh [directory]
set -euo pipefail
cd "$(dirname "$0")/.."
DIR="${1:-Sources/DesignSystem}"

FONTS="11 12 13 15 17 20"
SPACES="0 1 2 4 8 12 16 20 24 32 40 48"
RADII="4 6 8 12 16"
LINES="1 2"

out=$(mktemp)
trap 'rm -f "$out"' EXIT

# check KIND PATTERN RULE [ALLOWED]
# Greps PATTERN, takes the last number of each match and keeps the ones RULE rejects.
# RULE is "list" (the number must be in ALLOWED), "grid" (a multiple of 4, or 1 or 2),
# "tile" (the multiplier must be 0.25) or "never" (any match is wrong).
check() {
    local kind=$1 pattern=$2 rule=$3 allowed=${4:-}
    { grep -rnoE --include='*.swift' -- "$pattern" "$DIR" || true; } |
        awk -v kind="$kind" -v rule="$rule" -v allowed="$allowed" '
            BEGIN { n = split(allowed, a, " "); for (i = 1; i <= n; i++) ok[a[i] + 0] = 1 }
            {
                # file:line:match; the match itself may contain colons ("size: 12").
                file = $0; sub(/:.*/, "", file)
                rest = substr($0, length(file) + 2); line = rest; sub(/:.*/, "", line)
                m = substr(rest, length(line) + 2)
                sub(/^[^A-Za-z.]+/, "", m)
                num = m; sub(/.*[^0-9.]/, "", num)
                bad = 0
                if (rule == "never") bad = 1
                else if (rule == "list") bad = !((num + 0) in ok)
                else if (rule == "grid") { v = num + 0; bad = !(v == 1 || v == 2 || (v == int(v) && v % 4 == 0)) }
                else if (rule == "tile") bad = (num + 0 != 0.25)
                if (bad) printf "%s:%s: %s %s\n", file, line, kind, m
            }' >> "$out"
}

check "font size"      '\.system\(size: *[0-9.]+'                                       list "$FONTS"
check "font size"      'ofSize: *[0-9.]+'                                                list "$FONTS"
check "text style"     '\.font\(\.(largeTitle|title|title2|title3|headline|subheadline|body|callout|footnote|caption|caption2)[^A-Za-z0-9]' never
check "padding"        '\.padding\((\.[A-Za-z]+, *|\[[^]]*\], *)?[0-9.]+'                 list "$SPACES"
check "spacing"        '(spacing|Spacing|minLength): *[0-9.]+'                           list "$SPACES"
check "inset"          '(top|leading|bottom|trailing): *[0-9.]+'                         list "$SPACES"
check "corner radius"  'cornerRadius: *[0-9.]+'                                          list "$RADII"
check "corner radius"  'cornerRadius: *[A-Za-z_.]+ *\* *[0-9.]+'                         tile
check "size"           '(width|height|minWidth|maxWidth|minHeight|maxHeight|idealWidth|idealHeight): *[0-9.]+' grid
check "grid size"      '(minimum|maximum): *[0-9.]+'                                     grid
check "column width"   '[^A-Za-z](min|ideal|max): *[0-9.]+'                              grid
check "row height"     'rowHeight *= *[0-9.]+'                                           grid
check "line width"     'lineWidth: *[0-9.]+'                                             list "$LINES"

if [[ -s "$out" ]]; then
    sort -t: -k1,1 -k2,2n "$out"
    echo "$(wc -l < "$out" | tr -d ' ') size(s) off the scale in $DIR" >&2
    exit 1
fi
echo "Every size in $DIR is on the scale."
