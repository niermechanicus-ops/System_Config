#!/usr/bin/env bash
set -euo pipefail

wall_dir="$HOME/Documents/Wallpapers"
state_file="$HOME/.config/hypr/hyprpaper.conf"

# Pixel-art pass (2026-10-09): every menu here starts from the launcher's
# pixel theme (~/.config/rofi/pixel-launcher.rasi: Departure Mono, square
# crust frame with a rim, rows drawn as pixel buttons) and layers a small
# -theme-str on top for this script only.
#
# The image grid. Sized for the 4K panel this runs on: at 1100px the
# previews were small enough that picking between similar wallpapers meant
# guessing.
#
# On the empty space around each thumbnail: rofi fits an icon inside a
# SQUARE box whose side is `size`, and only `size` works — setting width and
# height on element-icon is ignored (rofi 2.0.0 collapses the icon to a tiny
# thumbnail instead). Wallpapers are 16:9, so ~44% of every box is
# necessarily empty. A filled accent-coloured selection (the launcher's
# mauve button face) would paint those bands solid, so the selected tile
# keeps a surface0 face and shows the selection as a mauve button outline
# instead. Removing the gap entirely would mean pre-generating square
# cropped thumbnails, which would drag in ImageMagick and a cache to keep
# warm; not worth it for a picker.
grid_theme='
window   { width: 1960px; }
listview { columns: 3; lines: 2; spacing: 10px; }
entry    { placeholder: "Wallpaper..."; }
element  { orientation: vertical; padding: 6px; spacing: 4px;
           children: [ element-icon, element-text ]; }
element-icon { size: 600px; horizontal-align: 0.5; background-color: transparent; }
element-text { horizontal-align: 0.5; }
element selected.normal { background-color: @bg1; text-color: @accent; border-color: @accent; }
'

# The small follow-up menus: no search bar, exactly as many rows as there are
# choices, labels centred in their buttons (like the power menu). The prompt
# that used to sit in the search bar moves to a message line above the rows.
small_theme() {
    printf '%s' "
window   { width: 760px; }
mainbox  { children: [ message, listview ]; }
listview { lines: $1; }
element-text { horizontal-align: 0.5; }
textbox  { horizontal-align: 0.5; }
message  { padding: 0 0 6px 0; }
"
}

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
        done | rofi -dmenu -i -show-icons -theme pixel-launcher -theme-str "$grid_theme"
    )
    [ -z "${chosen:-}" ] && exit 0
    img_path="$wall_dir/$chosen"

    # NOTE: printf reuses its format string once per argument, so
    # `printf "%s\nAll monitors\n" "${monitors[@]}"` emitted "All monitors"
    # once per monitor — four entries for two displays. Emit the monitors
    # with a single-placeholder format, then append the extra option once.
    target=$({ printf '%s\n' "${monitors[@]}"; echo "All monitors"; } \
        | rofi -dmenu -i -no-custom -mesg "Preview on" \
            -theme pixel-launcher -theme-str "$(small_theme $(( ${#monitors[@]} + 1 )))")
    [ -z "${target:-}" ] && exit 0

    apply_to "$target" "$img_path"

    decision=$(printf "Keep\nTry another wallpaper\nRevert\n" \
        | rofi -dmenu -i -no-custom -mesg "Check both monitors: $chosen -> $target" \
            -theme pixel-launcher -theme-str "$(small_theme 3)")

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
