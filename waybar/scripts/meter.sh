# Sourced by cpu-usage.sh and gpu-usage.sh. meter PCT CLASS prints an HP-bar
# made of PixelBar Icons glyphs: [ + 10 cells + ]. Rounds up, so any load at
# all lights the first cell and an idle machine still shows signs of life.
# Filled cells are the usage yellow (same as the icon), orange when busy;
# empty cells are the same dim plum as an empty workspace tile.
meter() {
    local pct=$1 class=$2 on=$'\U00100013' fill='#f9e2af' i out=""
    [ "$class" = busy ] && fill='#d77757'
    local n=$(( (pct + 9) / 10 )); (( n > 10 )) && n=10
    out="<span color='#7f7896'>"$'\U00100011'"</span><span color='$fill'>"
    for (( i = 0; i < n; i++ )); do out+=$on; done
    out+="</span><span color='#5c5675'>"
    for (( i = n; i < 10; i++ )); do out+=$on; done
    out+="</span><span color='#7f7896'>"$'\U00100012'"</span>"
    printf '%s' "$out"
}
