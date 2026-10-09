#!/usr/bin/env bash
# RGB chip for waybar. The gem is drawn in the bar's own blue rather than
# the LED colour: a live swatch clashed with the palette (and a red LED read
# as a warning). The exact colour is in the tooltip. Styling lives in
# waybar/style.css (.on / .off).
#
# Doesn't poll: rgb-set sends SIGRTMIN+9 whenever the colour changes.
set -uo pipefail

STATE_DIR=${XDG_STATE_HOME:-$HOME/.local/state}/rgb
color=$(cat "$STATE_DIR/color" 2>/dev/null || echo FF3000)

help='\n\nLeft-click   choose colour\nRight-click   on / off'

if [[ $color == 000000 ]]; then
	printf '{"text":"􀀈 OFF","tooltip":"RGB off%s","class":"off"}\n' "$help"
else
	printf '{"text":"􀀈 RGB","tooltip":"RGB #%s%s","class":"on"}\n' \
		"$color" "$help"
fi
