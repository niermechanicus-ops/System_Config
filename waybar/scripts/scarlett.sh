#!/usr/bin/env bash
# Waybar: Focusrite interface chip — a launcher for alsa-scarlett-gui that
# also reports what the interface is currently set to, on hover.
#
# The chip only exists while the interface is plugged in. Waybar hides a
# custom module whose "text" comes back empty, so unplugging the 2i2 removes
# the chip from the bar rather than leaving a button behind that opens a
# panel with nothing in it.
#
# The numbers come from the scarlett2 kernel driver, not from the GUI. That
# driver exposes the preamp gain, phantom power, input mode and Air setting
# as ordinary ALSA control elements, so the tooltip can report the same state
# the panel would show without the panel being open.
#
# Controls are looked up by NAME, never by numid. numids are handed out in
# whatever order the driver happens to register the controls and they do move
# between kernel and device-firmware versions; the names are stable.
#
# Gain: the control is an integer 0-70 with step 1 and a TLV minimum of
# 0.00 dB, so the raw value is read straight through as dB. The driver's
# advertised maximum is 69.00 dB, i.e. the top raw step is not a distinct
# gain setting — hence "0-69 dB" in the footer rather than 0-70.

set -uo pipefail

# Card index, not card name: the 2i2 registers its shortname as "Gen" (the
# last word of the model), which is both useless and liable to collide.
# /proc/asound/cards lists the index and the full model on the same line.
card=$(awk '
    /^[[:space:]]*[0-9]+[[:space:]]*\[/ { idx = $1 }
    /Scarlett|Clarett|Vocaster|Focusrite/ { if (idx != "") { print idx; exit } }
' /proc/asound/cards 2>/dev/null)

# No interface: empty text, and waybar drops the chip.
if [ -z "${card:-}" ]; then
    printf '{"text":"","tooltip":"","class":"absent"}\n'
    exit 0
fi

model=$(awk -v c="$card" '
    $1 == c && /\[/ { sub(/.*- /, ""); print; exit }
' /proc/asound/cards 2>/dev/null)
[ -n "${model:-}" ] || model="Focusrite interface"

# Cache one amixer dump per control we read. Each cget is a separate USB
# round trip to the device, so this keeps the whole refresh to a handful.
ctl() { amixer -c "$card" cget name="$1" 2>/dev/null; }

# Raw current value: the last line of a cget is "  : values=<v>".
val() { printf '%s' "${1-}" | awk -F= '/^[[:space:]]*: values=/ { print $2; exit }'; }

# Enumerated controls report an index; the labels are in the "; Item #N 'x'"
# lines above it. Map one to the other rather than printing a bare number.
enum() {
    printf '%s' "${1-}" | awk -v want="$(val "${1-}")" '
        match($0, /^[[:space:]]*; Item #([0-9]+) .(.*).$/, m) {
            if (m[1] == want) { print m[2]; exit }
        }'
}

in1=$(ctl 'Line In 1 Gain Capture Volume')
in2=$(ctl 'Line In 2 Gain Capture Volume')
lvl1=$(ctl 'Line In 1 Level Capture Enum')
lvl2=$(ctl 'Line In 2 Level Capture Enum')
air1=$(ctl 'Line In 1 Air Capture Enum')
air2=$(ctl 'Line In 2 Air Capture Enum')
p48=$(ctl 'Line In 1-2 Phantom Power Capture Switch')
mon=$(ctl 'Direct Monitor Playback Enum')

# Minimal JSON string escaping — model names come from the device.
esc() { printf '%s' "${1-}" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

# One input's line: gain, Line/Inst, and Air only when it is doing something.
input_line() {
    local label=$1 gain=$2 level=$3 air=$4 out
    out="$label"
    if [ -n "$gain" ]; then out+="   ${gain} dB"; else out+="   --"; fi
    [ -n "$level" ] && out+=" · $level"
    [ -n "$air" ] && [ "$air" != "Off" ] && out+=" · Air $air"
    printf '%s' "$out"
}

lines=("<b>$(esc "$model")</b>")
lines+=("$(input_line 'In 1' "$(val "$in1")" "$(enum "$lvl1")" "$(enum "$air1")")")
lines+=("$(input_line 'In 2' "$(val "$in2")" "$(enum "$lvl2")" "$(enum "$air2")")")

phantom=$(val "$p48")
[ -n "${phantom:-}" ] && lines+=("48V    $phantom")

monitor=$(enum "$mon")
[ -n "${monitor:-}" ] && lines+=("Direct monitor    $monitor")

lines+=("" "Gain range 0-69 dB · click to open the control panel")

# waybar's JSON parser wants literal \n escapes here, not real newlines.
tooltip=""
for i in "${!lines[@]}"; do
    [ "$i" -gt 0 ] && tooltip+="\\n"
    tooltip+="$(esc "${lines[$i]}")"
done

printf '{"text":"󰍬","tooltip":"%s","class":"connected"}\n' "$tooltip"
