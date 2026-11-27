#!/usr/bin/env bash
# Checks the GlamorGallery window on this Mac, as a user sees it, with no person at the keyboard:
#   pixel contrast (search placeholder, Deploy label, unfocused search edge, the switch-on track) in light and dark, and with the
#   Increase contrast colours (the gallery's debug flag; SwiftUI's own environment values cannot be set); the label-to-icon gap on the Daily menu button; the VoiceOver strings and
#   AXPress, and the names that appear only after an action (the theme switch after the toggle, "Clear the search"
#   after typing, the sheet title as a heading, the unlabelled spinner "Working"); Tab order, Space and Return.
#   The button shape (a Button is a capsule: its corner reads the ground) and the Pro and Soon marks (the marks scene) too.
# The gallery shows one scene per run (--scene <name>); each scene has its own list of controls in
# scripts/window/WindowCheck.swift. The run lines at the end say which scene each one uses.
# Only that window is captured. Light and dark are the gallery's own appearance (a launch argument); the
# system's appearance, Reduce Transparency, Increase Contrast and Keyboard navigation are never changed.
#
# Needs macOS 26, and Accessibility and Screen Recording permission for the app that runs it.
# Exit 0: no check failed. Exit 1: a check failed. Exit 2: it could not run. With --strict, an UNPROVEN line
# (something the system would not let it test without a settings change) also exits 1.
# Screenshots and tables: GLAMOR_WINDOW_OUT (default .build/window-check).
#
# Usage: scripts/check-window.sh [--strict]
set -uo pipefail
cd "$(dirname "$0")/.."
OUT="$(mkdir -p "${GLAMOR_WINDOW_OUT:-.build/window-check}" && cd "${GLAMOR_WINDOW_OUT:-.build/window-check}" && pwd)"
STRICT=0
[ "${1:-}" = "--strict" ] && STRICT=1

[ "$(sw_vers -productVersion | cut -d. -f1)" -ge 26 ] || { echo "needs macOS 26 or later" >&2; exit 2; }

# --strict needs Keyboard navigation on (System Settings, Keyboard): without it Tab and Space cannot be tested and
# every key check would end UNPROVEN after ten minutes. Stop at once with a plain line instead.
if [ "$STRICT" = 1 ]; then
    kbmode=$(defaults read NSGlobalDomain AppleKeyboardUIMode 2>/dev/null || echo 0)
    [ "$kbmode" -ge 2 ] || { echo "Keyboard navigation is off: turn it on in System Settings, Keyboard, then run again" >&2; exit 2; }
fi

# One run at a time, and not under load: wait for the self-hosted runner, and for a 1-minute load under 10.
RUN=()
[ -x "$HOME/.claude/bin/when-runner-idle" ] && RUN=("$HOME/.claude/bin/when-runner-idle")
for _ in $(seq 1 60); do
    load=$(uptime | sed -E 's/.*load averages?: ([0-9]+)[.,].*/\1/')
    [ "$load" -lt 10 ] && break
    sleep 5
done
[ "$load" -lt 10 ] || { echo "load average $load is 10 or more; not running" >&2; exit 2; }

"${RUN[@]}" swift build --product GlamorGallery >"$OUT/build.log" 2>&1 || { tail -20 "$OUT/build.log" >&2; exit 2; }
GALLERY="$(swift build --show-bin-path)/GlamorGallery"
mkdir -p "$OUT/bin"
"${RUN[@]}" swiftc -O -o "$OUT/bin/windowcheck" scripts/window/WindowCheck.swift >"$OUT/helper-build.log" 2>&1 \
    || { tail -20 "$OUT/helper-build.log" >&2; exit 2; }
CHECK="$OUT/bin/windowcheck"

PID=""
stop() { [ -n "$PID" ] && kill "$PID" 2>/dev/null && wait "$PID" 2>/dev/null; PID=""; }
trap stop EXIT

failed=0
unproven=0
# scene <name>: the gallery scene the run lines after it use (the gallery's --scene, the name of its list in WindowCheck.swift).
SCENE=components
scene() { SCENE=$1; }
# run <scenario> <mode> <gallery args...>: launch the gallery, run one mode against its PID, stop that PID.
# The gallery runs in English (-AppleLanguages): WindowCheck.swift looks controls up by their English names
# ("Daily", "Deploy"), so a Mac set to Indonesian would otherwise fail every lookup.
run() {
    local scenario=$1 mode=$2
    shift 2
    "$GALLERY" --scene "$SCENE" --log-activations "$@" -AppleLanguages '(en)' >"$OUT/gallery-$SCENE-$scenario-$mode.log" 2>&1 &
    PID=$!
    echo "== $SCENE / $scenario / $mode (gallery pid $PID)"
    for _ in $(seq 1 40); do "$CHECK" ready "$PID" "$SCENE" && break; sleep 0.5; done
    "$CHECK" ready "$PID" "$SCENE" || { echo "the gallery window did not appear" >&2; stop; failed=2; return; }
    # An inactive window gets the system's inactive material (grey, untinted), so the pixel checks must run
    # with the gallery in front: bring that one process forward by PID (no other app is touched).
    osascript -e "tell application \"System Events\" to set frontmost of (first process whose unix id is $PID) to true" >/dev/null 2>&1 || true
    sleep 1
    front=$(osascript -e "tell application \"System Events\" to get frontmost of (first process whose unix id is $PID)" 2>/dev/null || echo unknown)
    echo "WINDOW	$scenario	gallery is the front app: $front"
    echo "ENV	$scenario	$(grep '^environment:' "$OUT/gallery-$SCENE-$scenario-$mode.log" | head -1)"
    local out status
    out=$("$CHECK" "$mode" "$PID" "$scenario" "$OUT" "$SCENE"); status=$?
    echo "$out"
    [ $status -eq 1 ] && failed=1
    [ $status -ge 2 ] && { echo "windowcheck stopped with status $status" >&2; stop; exit 2; }
    echo "$out" | grep -q '^UNPROVEN' && unproven=1
    stop
}

scene components
run light pixels --appearance light
run dark pixels --appearance dark
run light-increased pixels --appearance light --increase-contrast
run dark-increased pixels --appearance dark --increase-contrast
run light strings --appearance light
run light sheet --appearance light --open-sheet
run light keys --appearance light

scene sidebar-a
run light pixels --appearance light
run dark pixels --appearance dark
run light-increased pixels --appearance light --increase-contrast
run dark-increased pixels --appearance dark --increase-contrast
run light strings --appearance light
run light keys --appearance light

scene sidebar-b
run light pixels --appearance light
run dark pixels --appearance dark
run light-increased pixels --appearance light --increase-contrast
run dark-increased pixels --appearance dark --increase-contrast
run light strings --appearance light
run light keys --appearance light

scene profile
run light pixels --appearance light
run dark pixels --appearance dark
run light-increased pixels --appearance light --increase-contrast
run dark-increased pixels --appearance dark --increase-contrast
run light strings --appearance light
run light keys --appearance light

# The Pro and Soon marks (GL36): word and outline pixels in four modes, and the spoken words.
scene marks
run light pixels --appearance light
run dark pixels --appearance dark
run light-increased pixels --appearance light --increase-contrast
run dark-increased pixels --appearance dark --increase-contrast
run light strings --appearance light

echo "== screenshots and tables: $OUT"
[ "$failed" -eq 0 ] || { echo "FAILED: see the FAIL lines above"; exit 1; }
[ "$STRICT" -eq 1 ] && [ "$unproven" -eq 1 ] && { echo "FAILED: --strict and something is UNPROVEN"; exit 1; }
echo "no check failed$([ "$unproven" -eq 1 ] && echo '; UNPROVEN lines above were not tested')"
