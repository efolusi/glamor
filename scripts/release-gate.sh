#!/usr/bin/env bash
# The local release gate: the checks CI runs (.github/workflows/checks.yml), then the window check.
# The window check needs a logged-in macOS 26 session with Accessibility and Screen Recording permission,
# so CI does not run it; this script is the one place that does, before a tag.
# Every step runs even when an earlier one fails. Exit 0: every step passed. Exit 1: a step failed.
# Output of each step goes to GLAMOR_GATE_OUT (default .build/release-gate); the summary goes to the terminal.
#
# Usage: scripts/release-gate.sh [--strict]    # --strict also fails the window check on UNPROVEN lines
set -uo pipefail
cd "$(dirname "$0")/.."
OUT="$(mkdir -p "${GLAMOR_GATE_OUT:-.build/release-gate}" && cd "${GLAMOR_GATE_OUT:-.build/release-gate}" && pwd)"
STRICT=()
[ "${1:-}" = "--strict" ] && STRICT=(--strict)

# One run at a time: wait for the self-hosted runner when the helper exists. Check `uptime` yourself first:
# a run under a 1-minute load of 10 or more fails for no reason.
RUN=()
[ -x "$HOME/.claude/bin/when-runner-idle" ] && RUN=("$HOME/.claude/bin/when-runner-idle")

FAILED=0
step() {
    local name="$1"; shift
    if "${RUN[@]}" "$@" >"$OUT/$name.log" 2>&1; then
        echo "PASS   $name"
    else
        echo "FAIL   $name (exit $?, see $OUT/$name.log)"
        FAILED=$((FAILED + 1))
    fi
}

step vendor-tokens scripts/vendor-tokens.sh --check
step check-colors scripts/check-colors.sh
step check-sizes scripts/check-sizes.sh
step check-motion scripts/check-motion.sh
step swift-test swift test
step ios-build xcodebuild build -scheme Glamor -destination 'generic/platform=iOS' -quiet

if [ "$(sw_vers -productVersion | cut -d. -f1)" -ge 26 ]; then
    step window-check scripts/check-window.sh "${STRICT[@]}"
    echo "       window lines: PASS $(grep -c '^PASS' "$OUT/window-check.log"), FAIL $(grep -c '^FAIL' "$OUT/window-check.log"), UNPROVEN $(grep -c '^UNPROVEN' "$OUT/window-check.log")"
else
    echo "FAIL   window-check (needs macOS 26 or later)"
    FAILED=$((FAILED + 1))
fi

[ "$FAILED" -eq 0 ] && { echo "release gate: every step passed"; exit 0; }
echo "release gate: $FAILED step(s) failed"
exit 1
