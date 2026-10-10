#!/usr/bin/env bash
# Time-of-day clock for waybar: a pixel sun, sunset or moon before the time,
# and the time's colour drifts with the day (style.css: .day/.dusk/.night).
#
#   06-17  day    sun     (yellow)    time peach
#   17-21  dusk   sunset  (peach)     time pink
#   21-06  night  moon    (lavender)  time lavender
#
# Runs forever and prints a line only when the minute changes. It checks every
# few seconds rather than sleeping to the next minute, because sleep doesn't
# count time spent suspended: after a resume a long sleep would leave the
# clock showing the time you shut the lid.
set -uo pipefail

last=""
while :; do
    printf -v now '%(%H:%M)T' -1
    if [ "$now" != "$last" ]; then
        last=$now
        h=$((10#${now%%:*}))
        if   (( h >= 6 && h < 17 )); then class=day   icon=$'\U00100014' tint='#f9e2af'
        elif (( h >= 17 && h < 21 )); then class=dusk icon=$'\U00100015' tint='#fab387'
        else                              class=night icon=$'\U00100016' tint='#b4befe'
        fi
        printf '{"text":"<span color='"'"'%s'"'"'>%s</span> %s","class":"%s"}\n' \
            "$tint" "$icon" "$now" "$class"
    fi
    sleep 2
done
