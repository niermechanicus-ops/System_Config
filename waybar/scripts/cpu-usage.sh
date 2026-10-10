#!/usr/bin/env bash
# CPU utilisation meter for waybar. Styling lives in waybar/style.css
# (.normal / .busy).
#
# Utilisation is the delta of /proc/stat's aggregate "cpu" line between this
# run and the previous one, so with interval 5 the number is the average over
# the last 5s — not an instantaneous spike, and no sleep inside the script.
# The previous sample is kept in $XDG_RUNTIME_DIR, like the temp chips' state.
#
# Only two states, unlike the temp chips: a pegged CPU is busy, not broken, so
# it gets orange ("look at me") but never red ("something is wrong").
set -uo pipefail

BUSY=85
STATE="${XDG_RUNTIME_DIR:-/tmp}/waybar-cpu-usage.prev"

# user nice system idle iowait irq softirq steal (guest is already in user)
read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
idle_now=$(( idle + iowait ))
total_now=$(( user + nice + system + idle + iowait + irq + softirq + steal ))

# First run after login has no previous sample, so it reports the average
# since boot; every run after that is a true 5s window.
idle_prev=0 total_prev=0
[ -r "$STATE" ] && read -r idle_prev total_prev < "$STATE"
printf '%s %s\n' "$idle_now" "$total_now" > "$STATE"

dt=$(( total_now - total_prev ))
di=$(( idle_now - idle_prev ))
(( dt > 0 )) && pct=$(( (100 * (dt - di) + dt / 2) / dt )) || pct=0

(( pct >= BUSY )) && class=busy || class=normal

read -r l1 l5 l15 _ < /proc/loadavg
. "$(dirname "$0")/meter.sh"
printf '{"text":"%s","tooltip":"CPU %d%% (5s average)\\nload %s / %s / %s on %d threads","class":"%s"}\n' \
    "$(meter "$pct" "$class")" "$pct" "$l1" "$l5" "$l15" "$(nproc)" "$class"
