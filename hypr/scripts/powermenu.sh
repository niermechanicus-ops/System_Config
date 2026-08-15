#!/usr/bin/env bash
# Power menu — SUPER + ESCAPE.
# Two options, rofi-driven, Catppuccin Mocha (inherits ~/.config/rofi/catppuccin-mocha.rasi).
set -euo pipefail

reboot_entry="  Reboot"
poweroff_entry="  Power Off"

# Compact override scoped to this invocation only — no search bar, exactly two
# rows, narrow window. Doesn't touch the shared theme file.
theme_str='
window   { width: 340px; padding: 14px; }
mainbox  { children: [ listview ]; }
listview { lines: 2; spacing: 6px; }
element  { padding: 12px 14px; }
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
