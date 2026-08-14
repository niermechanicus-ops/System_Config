#!/usr/bin/env bash
set -euo pipefail

wall_dir="$HOME/Documents/Wallpapers"
state_file="$HOME/.config/hypr/hyprpaper.conf"

# Thumbnail grid theme override for the image picker only (doesn't touch
# the shared rofi theme used by drun/run/window/monitor-picker/confirm menus).
#
# Sized for the 4K panel this runs on: at 1100px the previews were small
# enough that picking between similar wallpapers meant guessing.
#
# On the empty space around each thumbnail: rofi fits an icon inside a
# SQUARE box whose side is `size`, and only `size` works — setting width and
# height on element-icon is ignored (rofi 2.0.0 collapses the icon to a tiny
# thumbnail instead). Wallpapers are 16:9, so ~44% of every box is
# necessarily empty. That is invisible against the dark backdrop, but a
# filled accent-coloured selection paints those bands solid and makes them
# very obvious — so selection is a muted surface fill with accent text
# rather than a solid mauve block. Removing the gap entirely would mean
# pre-generating square cropped thumbnails, which would drag in ImageMagick
# and a cache to keep warm; not worth it for a picker.
grid_theme='
window { width: 1960px; padding: 18px; border: 0; }
mainbox { spacing: 14px; }
listview { columns: 3; lines: 2; spacing: 10px; scrollbar: false; }
element { orientation: vertical; padding: 6px; border-radius: 10px; spacing: 4px; }
element-icon { size: 600px; horizontal-align: 0.5; }
element-text { horizontal-align: 0.5; }
element selected.normal { background-color: #313244; text-color: #cba6f7; }
'

mapfile -t images < <(find "$wall_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -printf "%f\n" | sort)

if [ "${#images[@]}" -eq 0 ]; then
    notify-send "Wallpaper picker" "No images found in $wall_dir"
    exit 1
fi

mapfile -t monitors < <(hyprctl monitors | awk '/^Monitor /{print $2}')

# Snapshot the real current state up front so a cancelled/reverted preview
# always has something correct to restore.
declare -A current
while read -r mon; do
    line=$(hyprctl hyprpaper listactive 2>/dev/null | grep "^$mon: " || true)
    current["$mon"]="${line#"$mon: "}"
done < <(printf "%s\n" "${monitors[@]}")
declare -A original=()
for mon in "${monitors[@]}"; do
    original["$mon"]="${current[$mon]:-}"
done

apply_to() {
    local target="$1" path="$2"
    if [ "$target" = "All monitors" ]; then
        for mon in "${monitors[@]}"; do
            hyprctl hyprpaper wallpaper "$mon,$path" >/dev/null
            current["$mon"]="$path"
        done
    else
        hyprctl hyprpaper wallpaper "$target,$path" >/dev/null
        current["$target"]="$path"
    fi
}

revert() {
    for mon in "${monitors[@]}"; do
        if [ -n "${original[$mon]:-}" ] && [ "${current[$mon]:-}" != "${original[$mon]}" ]; then
            hyprctl hyprpaper wallpaper "$mon,${original[$mon]}" >/dev/null
            current["$mon"]="${original[$mon]}"
        fi
    done
}

persist() {
    {
        echo "splash = false"
        echo
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
}

while true; do
    chosen=$(
        for img in "${images[@]}"; do
            printf '%s\x00icon\x1f%s\n' "$img" "$wall_dir/$img"
        done | rofi -dmenu -i -show-icons -p "Wallpaper" -theme-str "$grid_theme"
    )
    [ -z "${chosen:-}" ] && exit 0
    img_path="$wall_dir/$chosen"

    # NOTE: printf reuses its format string once per argument, so
    # `printf "%s\nAll monitors\n" "${monitors[@]}"` emitted "All monitors"
    # once per monitor — four entries for two displays. Emit the monitors
    # with a single-placeholder format, then append the extra option once.
    target=$({ printf '%s\n' "${monitors[@]}"; echo "All monitors"; } \
        | rofi -dmenu -i -p "Preview on")
    [ -z "${target:-}" ] && exit 0

    apply_to "$target" "$img_path"

    decision=$(printf "Keep\nTry another wallpaper\nRevert\n" | rofi -dmenu -i -p "Applied — check both monitors" -mesg "$chosen -> $target")

    case "$decision" in
        Keep)
            persist
            notify-send -i "$img_path" "Wallpaper set" "$chosen -> $target"
            exit 0
            ;;
        "Try another wallpaper")
            continue
            ;;
        *)
            revert
            exit 0
            ;;
    esac
done
