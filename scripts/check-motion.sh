#!/usr/bin/env bash
# Checks that Glamor views move only through the motion tokens (guidelines/overview.md › Motion).
#
# Fails on a literal curve, duration or loop anywhere but DesignSystem/Motion.swift
# (and DesignSystemMobile/Motion.swift):
#   withAnimation(  .animation(  .transition(  .spring  .easeIn  .easeOut  .easeInOut  .linear(
#   .bouncy  .snappy  .smooth  .interpolatingSpring  .repeatForever  .repeatCount  .repeating
# Views use kAnimation(.base, value:), kTransition(.appear(from: .top)) and withKAnimation(.base) { }.
#
# Usage: scripts/check-motion.sh [directory]
set -euo pipefail
cd "$(dirname "$0")/.."
DIR="${1:-Sources/DesignSystem}"
ALLOWED='DesignSystem/Motion\.swift|DesignSystemMobile/Motion\.swift'

PATTERN='\bwithAnimation\b|\.animation\(|\.transition\(|\.spring\b|\.easeIn\b|\.easeOut\b|\.easeInOut\b|\.linear\(|\.bouncy\b|\.snappy\b|\.smooth\b|\.interpolatingSpring\b|\.repeatForever\b|\.repeatCount\b|\.repeating\b'

found=$({ grep -rnE --include='*.swift' -- "$PATTERN" "$DIR" || true; } | grep -vE "/($ALLOWED):" || true)
if [ -n "$found" ]; then
    echo "$found"
    echo "Motion outside the tokens: use K.Motion (kAnimation, kTransition, withKAnimation) on desktop, MK.Motion (mkAnimation, withMKAnimation) on phone, from DesignSystem Motion.swift." >&2
    exit 1
fi
echo "Motion: every animation in $DIR uses the motion tokens."
