#!/usr/bin/env bash
set -euo pipefail

wall_dir="$HOME/Documents/Wallpapers"
state_file="$HOME/.config/hypr/hyprpaper.conf"

mapfile -t images < <(find "$wall_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -printf "%f\n" | sort)

if [ "${#images[@]}" -eq 0 ]; then
    notify-send "Wallpaper picker" "No images found in $wall_dir"
    exit 1
fi

chosen=$(printf "%s\n" "${images[@]}" | rofi -dmenu -i -p "Wallpaper")
[ -z "${chosen:-}" ] && exit 0
img_path="$wall_dir/$chosen"

mapfile -t monitors < <(hyprctl monitors | awk '/^Monitor /{print $2}')
target=$(printf "%s\nAll monitors\n" "${monitors[@]}" | rofi -dmenu -i -p "Apply to")
[ -z "${target:-}" ] && exit 0

declare -A current
while read -r mon; do
    line=$(hyprctl hyprpaper listactive 2>/dev/null | grep "^$mon: " || true)
    current["$mon"]="${line#"$mon: "}"
done < <(printf "%s\n" "${monitors[@]}")

if [ "$target" = "All monitors" ]; then
    for mon in "${monitors[@]}"; do
        hyprctl hyprpaper wallpaper "$mon,$img_path" >/dev/null
        current["$mon"]="$img_path"
    done
else
    hyprctl hyprpaper wallpaper "$target,$img_path" >/dev/null
    current["$target"]="$img_path"
fi

{
    for mon in "${monitors[@]}"; do
        if [ -n "${current[$mon]:-}" ]; then
            echo "wallpaper {"
            echo "    monitor = $mon"
            echo "    path = ${current[$mon]}"
            echo "}"
            echo
        fi
    done
} > "$state_file"

notify-send -i "$img_path" "Wallpaper set" "$chosen -> $target"
