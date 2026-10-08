#!/usr/bin/env bash
# Power menu — SUPER + ESCAPE.
# Two options, rofi-driven, Catppuccin Mocha (inherits ~/.config/rofi/catppuccin-mocha.rasi).
set -euo pipefail

reboot_entry="  Reboot"
poweroff_entry="  Power Off"

# Compact override scoped to this invocation only — no search bar, exactly two
# rows, narrow window. Doesn't touch the shared theme file.
#
# Angular: every border-radius is 0, overriding the 12px/8px rounding the shared
# catppuccin-mocha.rasi sets.
#
# Colors: warm/umber shift of Mocha rather than the mauve accent. The mauve
# selection was unreadable because the shared theme paints the selected label in
# @bg0 — which carries an "ee" alpha — so dark text went translucent over bright
# purple. Both selection colors below are fully opaque.
theme_str='
* {
    umber-bg:   #1e1b19f5;  /* warm-shifted Mocha base                  */
    umber-sel:  #402319;    /* deep umber, Claude orange toward mantle  */
    umber-line: #5c3122;    /* one step up, for the frame               */
    sel-fg:     #f59575;    /* Claude shimmer orange, opaque            */
}

window {
    background-color: @umber-bg;
    border:           2px;
    border-color:     @umber-line;
    border-radius:    0;
    width:            340px;
    padding:          14px;
}

mainbox  { children: [ listview ]; }
listview { lines: 2; spacing: 6px; }

element {
    padding:       12px 14px;
    border-radius: 0;
}

element selected.normal {
    background-color: @umber-sel;
    text-color:       @sel-fg;
}
'

choice=$(printf '%s\n%s\n' "$reboot_entry" "$poweroff_entry" \
	| rofi -dmenu -i \
		-no-custom \
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
