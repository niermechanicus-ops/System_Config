#!/usr/bin/env bash
# Waybar: is this machine actually on the internet?
#
# Deliberately uses NetworkManager's connectivity state rather than the
# interface carrier flag. A cable can be plugged in, the link up and an IP
# assigned while there is still no route out — carrier would call that
# "online" and be wrong. NM already runs a real reachability probe on a
# timer, so reading its verdict costs nothing and needs no ping of our own.
#
# nmcli connectivity returns: full | limited | portal | none | unknown.
# Only "full" is ONLINE. The rest are all OFFLINE in the bar (as asked) but
# the tooltip says which, because they need different fixes: "limited" is a
# routing/DNS problem, "portal" means a login page is waiting, "none" is
# usually the cable or the router.

set -uo pipefail

state=$(nmcli networking connectivity 2>/dev/null || echo unknown)

# The interesting device is whichever one owns the default route, not
# whichever happens to be first in the interface list.
dev=$(ip route show default 2>/dev/null | awk '/^default/{print $5; exit}')

# Minimal JSON string escaping — connection names are user-set and can
# contain quotes or backslashes.
esc() { printf '%s' "${1-}" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

lines=()

if [ -n "${dev:-}" ]; then
    name=$(nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null \
           | awk -F: -v d="$dev" '$2==d{print $1; exit}')
    ip4=$(ip -4 -o addr show dev "$dev" 2>/dev/null | awk '{print $4; exit}')
    gw=$(ip route show default 2>/dev/null | awk '/^default/{print $3; exit}')
    # paste -d takes a *list* of delimiters and cycles them, so ', ' would
    # alternate comma and space rather than using both. Join on comma, then
    # space it out.
    dns=$(nmcli -t -f IP4.DNS device show "$dev" 2>/dev/null \
          | cut -d: -f2- | grep -v '^$' | paste -sd, - | sed 's/,/, /g')
    # Ethernet reports negotiated speed here; wireless reports -1/errors.
    speed=$(cat "/sys/class/net/$dev/speed" 2>/dev/null)

    [ -n "${name:-}" ] && lines+=("<b>$(esc "$name")</b>")

    if [ -n "${speed:-}" ] && [ "$speed" -gt 0 ] 2>/dev/null; then
        # Negotiated rate is worth showing: a 2.5G NIC sitting at 1000 Mb/s
        # means the switch or cable is the limit, which is invisible
        # otherwise.
        lines+=("$(esc "$dev") · ${speed} Mb/s")
    else
        # Wireless: SSID and signal are the useful pair.
        ssid=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null \
               | awk -F: '$1=="yes"{print $2" ("$3"%)"; exit}')
        if [ -n "${ssid:-}" ]; then
            lines+=("$(esc "$dev") · $(esc "$ssid")")
        else
            lines+=("$(esc "$dev")")
        fi
    fi

    [ -n "${ip4:-}" ] && lines+=("IP        $(esc "$ip4")")
    [ -n "${gw:-}"  ] && lines+=("Gateway   $(esc "$gw")")
    [ -n "${dns:-}" ] && lines+=("DNS       $(esc "$dns")")
fi

case "$state" in
    full)
        text="ONLINE"; class="online"
        ;;
    portal)
        text="OFFLINE"; class="offline"
        lines+=("" "Captive portal — a login page is waiting.")
        ;;
    limited)
        text="OFFLINE"; class="offline"
        lines+=("" "Connected, but no route to the internet.")
        ;;
    none)
        text="OFFLINE"; class="offline"
        if [ -z "${dev:-}" ]; then
            lines=("No default route — nothing is connected.")
        else
            lines+=("" "No internet access.")
        fi
        ;;
    *)
        text="OFFLINE"; class="offline"
        lines=("NetworkManager is not reporting a connectivity state.")
        ;;
esac

# Join the tooltip with literal \n escapes, which is what waybar's JSON
# parser expects (a real newline here would break the JSON).
tooltip=""
for i in "${!lines[@]}"; do
    [ "$i" -gt 0 ] && tooltip+="\\n"
    tooltip+="${lines[$i]}"
done

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$class" "$tooltip"
