#!/usr/bin/env bash
# RGB chip for waybar. The bulb is drawn in the colour the lights are set to,
# so the chip doubles as a swatch. Styling lives in waybar/style.css
# (.on / .off).
#
# Doesn't poll: rgb-set sends SIGRTMIN+9 whenever the colour changes.
set -uo pipefail

STATE_DIR=${XDG_STATE_HOME:-$HOME/.local/state}/rgb
color=$(cat "$STATE_DIR/color" 2>/dev/null || echo FF3000)

help='\n\nLeft-click   choose colour\nRight-click   on / off'

if [[ $color == 000000 ]]; then
	printf '{"text":"􀀈 OFF","tooltip":"RGB off%s","class":"off"}\n' "$help"
else
	printf '{"text":"<span color=\\"#%s\\">􀀈</span> RGB","tooltip":"RGB #%s%s","class":"on"}\n' \
		"$color" "$color" "$help"
fi
