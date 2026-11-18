#!/usr/bin/env bash
# Checks that Glamor views move only through the motion tokens (guidelines/overview.md › Motion).
#
# Fails on a literal curve, duration or loop anywhere but Sources/Glamor/macOS/Motion.swift
# (and Sources/Glamor/iOS/Motion+iOS.swift):
#   withAnimation(  .animation(  .transition(  .spring  .easeIn  .easeOut  .easeInOut  .linear(
#   .bouncy  .snappy  .smooth  .interpolatingSpring  .repeatForever  .repeatCount  .repeating
# Views use gAnimation(.base, value:), gTransition(.appear(from: .top)) and withGAnimation(.base) { }.
#
# Usage: scripts/check-motion.sh [directory]
set -euo pipefail
cd "$(dirname "$0")/.."
DIR="${1:-Sources/Glamor}"
ALLOWED='macOS/Motion\.swift|iOS/Motion\+iOS\.swift'

PATTERN='\bwithAnimation\b|\.animation\(|\.transition\(|\.spring\b|\.easeIn\b|\.easeOut\b|\.easeInOut\b|\.linear\(|\.bouncy\b|\.snappy\b|\.smooth\b|\.interpolatingSpring\b|\.repeatForever\b|\.repeatCount\b|\.repeating\b'

found=$({ grep -rnE --include='*.swift' -- "$PATTERN" "$DIR" || true; } | grep -vE "/($ALLOWED):" || true)
if [ -n "$found" ]; then
    echo "$found"
    echo "Motion outside the tokens: use G.Motion (gAnimation, gTransition, withGAnimation) from Glamor's Motion.swift." >&2
    exit 1
fi
echo "Motion: every animation in $DIR uses the motion tokens."
