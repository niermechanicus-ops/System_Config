#!/usr/bin/env bash
# CPU temperature chip for waybar, with a state class so the colour means
# something. Styling lives in waybar/style.css (.normal / .warm / .hot).
#
# Thresholds are hand-set, not read from the hardware: k10temp on this
# 9800X3D exposes only Tctl and Tccd1 via `sensors -j` — no temp1_crit — so
# there is nothing to derive them from. They come from the documented TjMax
# of 95 C:
#   warm 75  — working hard, entirely normal under sustained load
#   hot  88  — ~7 C off TjMax, the point where boost starts pulling back
#
# Note the reading is Tctl, the control temperature the boost algorithm
# actually acts on. It runs roughly 10-13 C above Tccd1, the die sensor, so
# this chip is the pessimistic of the two numbers by design.
set -uo pipefail

WARM=75
HOT=88
# Falling thresholds sit HYST degrees lower than rising ones, so a temperature
# parked on a boundary doesn't flip the chip's colour every 5s refresh.
HYST=2

STATE="${XDG_RUNTIME_DIR:-/tmp}/waybar-cpu-temp.class"

temp=$(sensors -j 2>/dev/null | grep -oP '"Tctl":\{"temp1_input":\K[0-9.]+')

if [ -z "$temp" ]; then
    printf '{"text":"--°C","tooltip":"CPU: sensor unavailable","class":"normal"}\n'
    exit 0
fi

# Integer copy for comparisons; the display value keeps its own rounding.
t=$(printf '%.0f' "$temp")
prev=$(cat "$STATE" 2>/dev/null || echo normal)

if   (( t >= HOT ));  then class=hot
elif (( t >= WARM )); then class=warm
else                       class=normal
fi

# Only let the class fall once the temperature has cleared the hysteresis band.
case "$prev" in
    hot)
        (( t >= HOT - HYST )) && class=hot
        ;;
    warm)
        if [ "$class" = normal ] && (( t >= WARM - HYST )); then class=warm; fi
        ;;
esac

printf '%s' "$class" > "$STATE"

case "$class" in
    hot)    note="hot — near TjMax 95°C" ;;
    warm)   note="warm — normal under load" ;;
    *)      note="normal" ;;
esac

printf '{"text":"%.0f°C","tooltip":"CPU Tctl %.1f°C — %s\\nwarm ≥%d°C, hot ≥%d°C","class":"%s"}\n' \
    "$temp" "$temp" "$note" "$WARM" "$HOT" "$class"
