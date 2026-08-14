# Recovery snapshot — paste this into a new Claude Code chat after a crash/reinstall

Machine: Arch Linux, Hyprland (Wayland, hyprland-uwsm). Hyprland config is LUA, not
hyprland.conf keyfile — file: ~/.config/hypr/hyprland.lua (hl.config/hl.bind/hl.on API).
CPU: AMD Ryzen 7 9800X3D. GPU: NVIDIA RTX 5080 (nvidia-open driver).
Wi-Fi/BT: MediaTek MT7927 — BT firmware not yet published upstream, bluetooth.service
spams retry errors, left running as-is on purpose (don't mask unless asked).

All dotfiles physically live in ~/Documents/dotfiles/, symlinked into ~/.config/<app>
(e.g. ~/.config/hypr -> ~/Documents/dotfiles/hypr). Edit either path, same file.
Bin scripts symlinked into ~/.local/bin.

Theme: Catppuccin Mocha everywhere. Stack: waybar + rofi + kitty + fastfetch, all themed.
Borders disabled (general.border_size = 0). Nerd font: JetBrainsMono Nerd Font.

Apps configured so far: hypr, waybar, rofi, kitty, fastfetch, nvim (LazyVim), mpv,
obs-studio (theme files present, not confirmed selected in-app), yazi (theme.toml only),
swayimg, gtk-3.0/gtk-4.0, kdeglobals (Dolphin), zsh (oh-my-zsh, login shell, but
ZSH_THEME is still default "robbyrussell" — prompt itself NOT yet Catppuccin-styled,
that's the next thing to finish).

DaVinci Resolve (free, via yay/AUR) is installed for video editing.
~/.local/bin/yt-mov <url>: downloads a YouTube video and re-encodes it into a
DaVinci-Resolve-friendly .mov in ~/Videos. IMPORTANT: must encode video as DNxHR
(dnxhd encoder, profile dnxhr_hq, yuv422p) + PCM audio — NOT H.264. Free Resolve on
Linux has no H.264 decoder (Studio/licensing-gated there specifically), so H.264 .mov
files import as audio-only with no video track. Already fixed once; if a fresh install
of this script is missing that fix, redo it.

Custom keybinds (SUPER = mainMod): SPACE=rofi drun, RETURN=kitty, W=firefox,
PRINT=full screenshot, SHIFT+PRINT=region screenshot (grim+slurp),
SHIFT+W=wallpaper picker (rofi-driven, ~/.config/hypr/scripts/wallpaper-picker.sh),
N=neovim scratchpad toggle (floating kitty+nvim on a special workspace).
Wallpapers live in ~/Documents/Wallpapers. Monitors: DP-3 = 4K main, HDMI-A-2 = 1080p
secondary (no waybar on the secondary).

hyprpaper gotcha: v0.8.4+ needs block-style wallpaper config
(`wallpaper { monitor = NAME; path = /path }`), not the old flat
`wallpaper = MONITOR,/path` syntax — check version before reusing old scripts.

Outstanding / next up:
- Switch zsh ZSH_THEME to something Catppuccin-styled (currently robbyrussell).
- Confirm obs-studio Catppuccin theme is actually selected in Settings > General, not
  just present as a file.
- gtk settings.ini references cursor theme "catppuccin-mocha-white" — double check that
  variant actually resolves (only "-dark" and "-mauve" cursor dirs were confirmed present
  as of 2026-08-14).
