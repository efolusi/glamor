#!/usr/bin/env bash
# Copies design-tokens' generated Swift values into Sources/Glamor/Generated/GlamorTokens.swift.
# The version is pinned in TOKENS_VERSION. With --check, fails when the copy differs from that version.
#
# Usage: scripts/vendor-tokens.sh [--check]
set -euo pipefail
cd "$(dirname "$0")/.."
TOKENS_VERSION="v0.1.1"
# The commit that tag points at. A moved tag fails here instead of changing the tokens.
TOKENS_COMMIT="ab2a6b11ae490849527206200c174184f1d20da6"
URL="https://raw.githubusercontent.com/efolusi/design-tokens/$TOKENS_COMMIT/tokens/native/GlamorTokens.swift"
OUT="Sources/Glamor/Generated/GlamorTokens.swift"

tagged=$(git ls-remote https://github.com/efolusi/design-tokens "refs/tags/$TOKENS_VERSION^{}" | cut -f1)
if [ "$tagged" != "$TOKENS_COMMIT" ]; then
    echo "design-tokens $TOKENS_VERSION points at ${tagged:-nothing}, not $TOKENS_COMMIT. Check the tag before updating TOKENS_COMMIT." >&2
    exit 1
fi

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
