#!/usr/bin/env bash
# Power menu — SUPER + ESCAPE.
# Two options, rofi-driven. Built on the pixel-art launcher theme
# (~/.config/rofi/pixel-launcher.rasi) with the warm umber colours below.
set -euo pipefail

reboot_entry="􀀋 Reboot"
poweroff_entry="􀀌 Power Off"

# Pixel-art pass (2026-10-09): starts from pixel-launcher.rasi (pixel font,
# square crust frame with a rim, rows drawn as pixel buttons) and overrides
# it, for this invocation only: no search bar, exactly two rows, narrow.
# Icons are PixelBar Icons glyphs (waybar/icons/icons.py: reboot, power).
#
# Colors: warm/umber shift of Mocha rather than the mauve accent, kept from
# before the pixel pass. The mauve selection was unreadable because the old
# shared theme painted the selected label in @bg0, which carries an "ee"
# alpha, so dark text went translucent over bright purple. Every colour used
# for the selection below is fully opaque.
theme_str='
* {
    umber-bg:    #1e1b19f5;  /* warm-shifted Mocha base                  */
    umber-sel:   #402319;    /* deep umber, Claude orange toward mantle  */
    umber-line:  #5c3122;    /* one step up, for the frame rim           */
    umber-crust: #120f0e;    /* warm crust, for outlines                 */
    sel-fg:      #f59575;    /* Claude shimmer orange, opaque            */
}

window {
    background-color: @umber-bg;
    border-color:     @umber-crust;
    width:            400px;
}

mainbox  { children: [ listview ]; border-color: @umber-line; }
listview { lines: 2; }

element selected.normal {
    background-color: @umber-sel;
    text-color:       @sel-fg;
    border-color:     @umber-crust;
}
'

choice=$(printf '%s\n%s\n' "$reboot_entry" "$poweroff_entry" \
	| rofi -dmenu -i \
		-no-custom \
		-theme pixel-launcher \
		-theme-str "$theme_str" \
		|| true)

# Exit Hyprland gracefully before the power action. Calling systemctl directly
# yanks the DRM session out from under Hyprland, which segfaults in libaquamarine
# or hangs until uwsm SIGKILLs it. hyprshutdown closes apps, exits Hyprland, then
# runs --post-cmd. It runs in its own scope because this script inherits
# wayland-wm@hyprland.desktop.service's cgroup, which systemd kills once Hyprland
# exits — before the post-cmd would get to run.
#
# hyprshutdown fires --post-cmd as soon as Hyprland drops its Wayland socket, but
# Hyprland still needs ~150ms to release DRM after that; powering off inside that
# window still segfaulted it (2026-10-08). So the post-cmd waits for the Hyprland
# process itself to be gone (capped at 5s) before the power action.
graceful() {
	local pid
	pid=$(pgrep -xo Hyprland || true)
	local wait_cmd=":"
	[[ -n $pid ]] && wait_cmd="timeout 5 tail --pid=$pid -s 0.1 -f /dev/null"
	systemd-run --user --scope --quiet -- \
		hyprshutdown --post-cmd "$wait_cmd; $1"
}

case "$choice" in
"$reboot_entry") graceful "systemctl reboot" ;;
"$poweroff_entry") graceful "systemctl poweroff" ;;
*) exit 0 ;; # Escape / dismissed
esac
