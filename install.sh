#!/usr/bin/env bash
# Recreates the symlinks this dotfiles repo relies on. Run from a fresh
# clone of this repo at ~/Documents/dotfiles (or edit DOTFILES below).
#
# Does NOT install packages or fonts — see README.md / .system/*.txt for
# that (it needs sudo/AUR and should be run/reviewed by hand).
set -euo pipefail

DOTFILES="$HOME/Documents/dotfiles"

link() {
    local src="$DOTFILES/$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "SKIP (real file/dir exists, not overwriting): $dst"
        return
    fi
    ln -sfn "$src" "$dst"
    echo "linked: $dst -> $src"
}

link hypr            "$HOME/.config/hypr"
link waybar           "$HOME/.config/waybar"
link rofi             "$HOME/.config/rofi"
link kitty            "$HOME/.config/kitty"
link fastfetch         "$HOME/.config/fastfetch"
link dunst            "$HOME/.config/dunst"
link nvim             "$HOME/.config/nvim"
link mpv              "$HOME/.config/mpv"
link swayimg           "$HOME/.config/swayimg"
link gtk-3.0           "$HOME/.config/gtk-3.0"
link gtk-4.0           "$HOME/.config/gtk-4.0"
link kdeglobals         "$HOME/.config/kdeglobals"
link color-schemes       "$HOME/.local/share/color-schemes"
link icons/catppuccin-mocha-dark-cursors  "$HOME/.local/share/icons/catppuccin-mocha-dark-cursors"
link icons/catppuccin-mocha-mauve-cursors "$HOME/.local/share/icons/catppuccin-mocha-mauve-cursors"
link zsh/zshrc          "$HOME/.zshrc"
link bashrc            "$HOME/.bashrc"
# See the file's own comment: routes ALSA's "default" through the PulseAudio
# plugin, which is the only path DaVinci Resolve's Fairlight input works on.
link asoundrc           "$HOME/.asoundrc"
link starship.toml        "$HOME/.config/starship.toml"
link bin/yt-mov          "$HOME/.local/bin/yt-mov"
link bin/idle-inhibit-media   "$HOME/.local/bin/idle-inhibit-media"
link systemd/idle-inhibit-media.service "$HOME/.config/systemd/user/idle-inhibit-media.service"
link bin/ram-rgb-off       "$HOME/.local/bin/ram-rgb-off"
link systemd/ram-rgb-off.service    "$HOME/.config/systemd/user/ram-rgb-off.service"

# Takes priority over plasma-workspace's claim on the notification bus name,
# which would otherwise leave notify-send hanging. See the file's own comment.
link dbus/org.knopwob.dunst.service "$HOME/.local/share/dbus-1/services/org.knopwob.dunst.service"

# obs-studio only symlinks its themes subdir; the rest of ~/.config/obs-studio
# is app state and shouldn't be managed here.
link obs-studio/themes     "$HOME/.config/obs-studio/themes"

echo
echo "Done. Still manual: install packages (.system/pacman-packages.txt,"
echo ".system/aur-packages.txt), install the Nerd Font, chsh -s /usr/bin/zsh,"
echo "install oh-my-zsh, and (for nvim) run: nvim --headless \"+Lazy! sync\" +qa"
echo
echo "Also manual: systemctl --user enable --now idle-inhibit-media.service ram-rgb-off.service"
