#!/usr/bin/env bash
# GPU temperature chip for waybar, with a state class so the colour means
# something. Styling lives in waybar/style.css (.normal / .warm / .hot).
#
# Thresholds are hand-set. This RTX 5080 reports its limits as *relative*
# T.Limit offsets rather than absolute temperatures —
#   nvidia-smi -q -d TEMPERATURE
# gives "Slowdown T.Limit: -2 C", "Max Operating T.Limit: 0 C", which are
# degrees relative to an undisclosed limit, not values to compare against. So
# these come from the documented ~90 C max operating temperature:
#   warm 78  — a busy GPU mid-game or mid-render sits here; not a problem
#   hot  86  — approaching thermal slowdown
#
# Deliberately higher than the CPU's warm threshold: 75 C is unremarkable for
# a loaded GPU but would be notable for this CPU.
set -uo pipefail

WARM=78
HOT=86
HYST=2

STATE="${XDG_RUNTIME_DIR:-/tmp}/waybar-gpu-temp.class"

temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | tr -d ' ')

# No driver, no card, or nvidia-smi failing: say so rather than showing 0°C.
if ! [[ "$temp" =~ ^[0-9]+$ ]]; then
    printf '{"text":"--°C","tooltip":"GPU: nvidia-smi unavailable","class":"normal"}\n'
    exit 0
fi

t=$temp
prev=$(cat "$STATE" 2>/dev/null || echo normal)

if   (( t >= HOT ));  then class=hot
elif (( t >= WARM )); then class=warm
else                       class=normal
fi

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
    hot)    note="hot — nearing thermal slowdown" ;;
    warm)   note="warm — normal under load" ;;
    *)      note="normal" ;;
esac

printf '{"text":"%s°C","tooltip":"GPU %s°C — %s\\nwarm ≥%d°C, hot ≥%d°C","class":"%s"}\n' \
    "$t" "$t" "$note" "$WARM" "$HOT" "$class"
