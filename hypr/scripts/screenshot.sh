#!/usr/bin/env bash
# Usage: screenshot.sh [full|region]
set -euo pipefail

dir="$HOME/Documents/Screenshots"
mkdir -p "$dir"
file="$dir/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

mode="${1:-full}"

if [ "$mode" = "region" ]; then
    geometry=$(slurp) || exit 0
    grim -g "$geometry" "$file"
else
    grim "$file"
fi

wl-copy < "$file"

if command -v notify-send >/dev/null 2>&1; then
    notify-send -i "$file" "Screenshot saved" "$(basename "$file")"
fi
