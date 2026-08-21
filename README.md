# System_Config

Arch Linux + Hyprland desktop: Catppuccin Mocha neutrals with Claude Code's dark
accent palette (see `PALETTE.md`) throughout. This repo is the
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

## Theme: Mocha neutrals, Claude Code accents

**`PALETTE.md` is the source of truth** — it has the full accent map, where each
value came from, and the command to re-derive them after a Claude Code update.

Hex codes are embedded in every themed config file (waybar `style.css`,
`rofi/catppuccin-mocha.rasi`, `kitty/catppuccin-mocha.conf`, `hypr/hyprland.lua`
border colors, `dunst/dunstrc`, `nvim/lua/plugins/colorscheme.lua`, `mpv/mpv.conf`,
obs-studio `.ovt`/`.obt` theme files) — nothing here is a "generate from a palette"
setup, the colors are just hardcoded per-app the way each tool expects. Quick
reference:

| Name       | Hex       | Source                        |
|------------|-----------|-------------------------------|
| Base       | `#1e1e2e` | Mocha                         |
| Mantle     | `#181825` | Mocha                         |
| Surface0   | `#313244` | Mocha                         |
| Surface1   | `#45475a` | Mocha                         |
| Text       | `#cdd6f4` | Mocha                         |
| Orange     | `#d77757` | Claude `claude` — the accent  |
| Shimmer    | `#f59575` | Claude `claudeShimmer`        |
| Purple     | `#af87ff` | Claude `autoAccept`           |
| Blue       | `#b1b9f9` | Claude `permission`           |
| Green      | `#4eba65` | Claude `success`              |
| Yellow     | `#ffc107` | Claude `warning`              |
| Red        | `#ff6b80` | Claude `error`                |

Files and scheme names still say "catppuccin" (`rofi/catppuccin-mocha.rasi`,
`CatppuccinMochaMauve.colors`) — those names are keys other things reference, so
renaming them would orphan the scheme for no gain.

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

- **`AUDIO.md`** — the audio chain (Cloudlifter into a Scarlett 2i2 4th Gen),
  PipeWire routing, the waybar audio chips, and the `asoundrc` workaround this
  machine needs before DaVinci Resolve will record anything but silence. Read it
  before touching `asoundrc`, which otherwise looks like a stray PulseAudio file
  on a PipeWire system.
- `bin/yt-mov`: downloads a YouTube video and transcodes it for DaVinci Resolve
  (free/non-Studio build). Must encode video as DNxHR (`dnxhd` encoder, profile
  `dnxhr_hq`, `yuv422p`), not H.264 — free Resolve on Linux has no H.264 decoder
  (that's licensing-gated to Studio there specifically), so an H.264 `.mov` imports
  into Resolve as audio-only with no video track. Output files are large (DNxHR HQ
  is an intermediate codec, ~20-30x the size of an H.264 encode).
