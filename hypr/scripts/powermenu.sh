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
    umber-bg:   #1e1b19f5;  /* warm-shifted Mocha base                 */
    umber-sel:  #4a3527;    /* deep umber, from peach pulled to mantle */
    umber-line: #6b4a35;    /* one step up, for the frame              */
    sel-fg:     #f5e0dc;    /* Catppuccin rosewater, opaque            */
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

case "$choice" in
"$reboot_entry") systemctl reboot ;;
"$poweroff_entry") systemctl poweroff ;;
*) exit 0 ;; # Escape / dismissed
esac
