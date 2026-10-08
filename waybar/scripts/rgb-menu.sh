#!/usr/bin/env bash
# Click handlers for the waybar RGB chip.
#
#   rgb-menu.sh          rofi colour picker (left-click)
#   rgb-menu.sh toggle   off <-> last colour (right-click)
#
# rgb-set does the actual work and takes a few seconds (OpenRGB re-detects
# every device on each call), so it's started in the background and the
# chip repaints straight away.
#
# rofi is pinned to DP-1 because that is the only output carrying the bar;
# otherwise it opens wherever keyboard focus happens to be.
set -uo pipefail

STATE_DIR=${XDG_STATE_HOME:-$HOME/.local/state}/rgb
current=$(cat "$STATE_DIR/color" 2>/dev/null || echo FF3000)

apply() {
	setsid -f "$HOME/.local/bin/rgb-set" "$1" >/dev/null 2>&1
}

if [[ ${1:-} == toggle ]]; then
	if [[ $current == 000000 ]]; then
		apply "$(cat "$STATE_DIR/last" 2>/dev/null || echo FF3000)"
	else
		apply 000000
	fi
	exit 0
fi

# name|hex. LEDs mix light, so these are tuned for how they look on the RAM
# and fans rather than on screen -- dark colours are dimmer, not browner.
presets=(
	"Orange|FF3000"
	"Burnt orange|803A00"
	"Dark umber|6B1E00"
	"Amber|FF7000"
	"Red|FF0000"
	"Pink|FF0050"
	"Purple|8000FF"
	"Blue|0030FF"
	"Cyan|00C0FF"
	"Green|00FF20"
	"White|FFFFFF"
)

rows=()
selected=0
for i in "${!presets[@]}"; do
	IFS='|' read -r name hex <<<"${presets[$i]}"
	rows+=("<span color=\"#$hex\">●</span>  $name  <span alpha=\"50%\">#$hex</span>")
	[[ $hex == "$current" ]] && selected=$i
done
rows+=("󰏘  Custom hex…" "󰌶  Off")
[[ $current == 000000 ]] && selected=$((${#rows[@]} - 1))

choice=$(printf '%s\n' "${rows[@]}" |
	rofi -dmenu -m DP-1 -l "${#rows[@]}" -i -markup-rows -no-custom -format i -selected-row "$selected" -p "RGB") || exit 0

n=${#presets[@]}
if ((choice < n)); then
	apply "${presets[$choice]#*|}"
elif ((choice == n)); then
	hex=$(rofi -dmenu -m DP-1 -p "Hex colour" -mesg "e.g. FF3000 (current #$current)" </dev/null) || exit 0
	hex=${hex#\#}
	if [[ $hex =~ ^[0-9A-Fa-f]{6}$ ]]; then
		apply "$hex"
	else
		notify-send -a RGB "RGB" "'$hex' isn't a 6-digit hex colour"
	fi
else
	apply 000000
fi
