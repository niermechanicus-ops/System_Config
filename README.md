# System_Config

Arch Linux + Hyprland desktop, themed Catppuccin Mocha throughout. This repo is the
actual config files (not copies) — `~/.config/<app>` is symlinked into this repo, so
editing either path edits the same file. See `.recovery/SNAPSHOT.md` for a short
plain-text summary meant to be pasted into a fresh Claude Code chat after a crash.

## Restoring on a fresh machine

0. **Reinstalling Arch itself first?** See `ARCHINSTALL.md` — it has the exact
   `archinstall` config used originally (disk/btrfs layout, bootloader, Hyprland
   profile, Nvidia driver choice, etc.), including a JSON file you can feed straight
   to `archinstall --config` instead of clicking through the menu from memory.
1. Install packages: `sudo pacman -S --needed - < .system/pacman-packages.txt`
   then the AUR ones in `.system/aur-packages.txt` (needs an AUR helper, e.g. `yay`
   — `yay -S davinci-resolve` etc.). These lists were captured with
   `pacman -Qqen` / `pacman -Qqem` on 2026-08-14 and will drift over time; treat as
   a starting point, not gospel.
2. Clone this repo to `~/Documents/dotfiles`.
3. Run `./install.sh` — recreates all the `~/.config/*` symlinks. It refuses to
   overwrite anything that isn't already a symlink, so it's safe to re-run.
4. Manual steps `install.sh` deliberately doesn't do:
   - `chsh -s /usr/bin/zsh`
   - install oh-my-zsh (`sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`)
   - `nvim --headless "+Lazy! sync" +qa` to pull LazyVim's plugins
   - set Dolphin's color scheme once (`kwriteconfig6` or just open Dolphin settings — `kdeglobals` alone isn't always picked up live)

## Theme: Catppuccin Mocha

Hex codes are already embedded in every themed config file (waybar `style.css`,
`rofi/catppuccin-mocha.rasi`, `kitty/catppuccin-mocha.conf`, `hypr/hyprland.lua`
border colors, `mpv/mpv.conf`, obs-studio `.ovt`/`.obt` theme files) — nothing here
is a "generate from a palette" setup, the colors are just hardcoded per-app the way
each tool expects. Quick reference if you need the raw values:

| Name       | Hex       |
|------------|-----------|
| Base       | `#1e1e2e` |
| Mantle     | `#181825` |
| Surface0   | `#313244` |
| Surface1   | `#45475a` |
| Text       | `#cdd6f4` |
| Mauve      | `#cba6f7` |
| Blue       | `#89b4fa` |
| Red        | `#eba0ac` (maroon-ish variant used for e.g. waybar warnings) |

(Full 26-color Catppuccin Mocha palette: https://catppuccin.com/palette — the table
above is only the ones actually reused across configs here, not the whole set.)

- **Font**: JetBrainsMono Nerd Font, package `ttf-jetbrains-mono-nerd` (AUR:
  `nerd-fonts` group). Used in kitty, waybar, gtk, mpv OSD, rofi.
- **Cursors**: `catppuccin-mocha-dark-cursors` and `catppuccin-mocha-mauve-cursors`
  are vendored as actual files under `icons/` (not from a package — pulled directly
  from catppuccin/cursors). gtk settings currently reference a `-white` variant that
  hasn't been confirmed to exist; check before relying on it.
- **Icon theme**: `breeze-dark` (package `breeze`), used for Dolphin/gtk.
- **Borders**: disabled everywhere (`general.border_size = 0` in `hypr/hyprland.lua`),
  except the Hyprland active-window border gradient itself (mauve → blue, see table).

## Known incomplete / drifted from "fully themed"

- zsh: `ZSH_THEME` in `zsh/zshrc` is still oh-my-zsh's default `robbyrussell`, not a
  Catppuccin prompt. Syntax-highlighting colors *are* Catppuccin
  (`zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh`), just not the prompt itself.
- obs-studio: Catppuccin theme files are present and symlinked into
  `~/.config/obs-studio/themes`, but whether the theme is actually *selected* in
  OBS's Settings > General hasn't been confirmed — file presence isn't the same as
  applied.

## Non-appearance stuff also in here

- `bin/yt-mov`: downloads a YouTube video and transcodes it for DaVinci Resolve
  (free/non-Studio build). Must encode video as DNxHR (`dnxhd` encoder, profile
  `dnxhr_hq`, `yuv422p`), not H.264 — free Resolve on Linux has no H.264 decoder
  (that's licensing-gated to Studio there specifically), so an H.264 `.mov` imports
  into Resolve as audio-only with no video track. Output files are large (DNxHR HQ
  is an intermediate codec, ~20-30x the size of an H.264 encode).
