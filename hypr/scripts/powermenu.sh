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
# Colours: the bar's two oranges rather than the launcher's mauve, so the
# menu reads as "this one's serious". Claude orange (#d77757) is the frame
# rim and the selected button's face; the clock's shimmer orange (#f59575) is
# the idle text. Selected text is opaque crust, so it stays solid on the
# orange face (the old shared theme used translucent @bg0 there, which is
# what made an earlier mauve version unreadable).
#
# Centring: rofi centres in the area below the bar (66px), which put the menu
# 32px low. It ignores y-offset when centred, so an empty 64px bottom margin
# is used instead: centring the window plus margin lifts the visible menu by
# 32px, to the true middle of the 4K screen. (On the 1080p monitor, which has
# no bar, it therefore sits 32px above centre.) Labels are centred inside
# their buttons too.
theme_str='
* {
    warm-bg:     #1e1b19f5;  /* warm-shifted Mocha base           */
    warm-crust:  #120f0e;    /* warm crust, for outlines          */
    claude:      #d77757;    /* Claude orange: rim, selected face */
    shimmer:     #f59575;    /* clock orange: idle text           */
}

window {
    background-color: @warm-bg;
    border-color:     @warm-crust;
    width:            400px;
    margin:           0 0 64px 0;
}

mainbox  { children: [ listview ]; border-color: @claude; }
listview { lines: 2; }

element-text { horizontal-align: 0.5; }

element normal.normal,
element alternate.normal {
    text-color: @shimmer;
}

element selected.normal {
    background-color: @claude;
    text-color:       @warm-crust;
    border-color:     @warm-crust;
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
