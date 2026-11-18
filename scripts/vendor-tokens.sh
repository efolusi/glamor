#!/usr/bin/env bash
# Copies design-tokens' generated Swift values into Sources/Glamor/Generated/GlamorTokens.swift.
# The version is pinned in TOKENS_VERSION. With --check, fails when the copy differs from that version.
#
# Usage: scripts/vendor-tokens.sh [--check]
set -euo pipefail
cd "$(dirname "$0")/.."
TOKENS_VERSION="v0.1.1"
URL="https://raw.githubusercontent.com/efolusi/design-tokens/$TOKENS_VERSION/tokens/native/GlamorTokens.swift"
OUT="Sources/Glamor/Generated/GlamorTokens.swift"

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
curl -fsSL "$URL" -o "$tmp"

if [ "${1:-}" = "--check" ]; then
    if ! cmp -s "$tmp" "$OUT"; then
        echo "$OUT is not design-tokens $TOKENS_VERSION. Run scripts/vendor-tokens.sh." >&2
        exit 1
    fi
    echo "Tokens: $OUT matches design-tokens $TOKENS_VERSION."
    exit 0
fi
cp "$tmp" "$OUT"
echo "Tokens: copied design-tokens $TOKENS_VERSION into $OUT."
