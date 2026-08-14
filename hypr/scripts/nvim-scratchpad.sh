#!/usr/bin/env bash
set -euo pipefail

if ! hyprctl clients -j | grep -q '"class":[[:space:]]*"scratchpad-nvim"'; then
    last_file=$(timeout 3 nvim --headless -u NONE -c 'set shortmess+=A' -c 'lua io.write(vim.v.oldfiles[1] or "")' -c 'qa!' 2>/dev/null || true)
    if [ -n "$last_file" ] && [ -f "$last_file" ]; then
        kitty --class scratchpad-nvim -e nvim "$last_file" &
    else
        kitty --class scratchpad-nvim -e nvim &
    fi
    sleep 0.3
fi

hyprctl dispatch 'hl.dsp.workspace.toggle_special("scratchpad")' >/dev/null
