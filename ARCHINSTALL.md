# archinstall settings

This is what was actually chosen when this machine was installed on 2026-08-14,
recovered from `/var/log/archinstall/install.log` (archinstall logs its final
config as JSON before applying it).

## Fastest path: non-interactive

`.system/archinstall-config.json` is that exact config, straight from the log.
Boot the Arch ISO, connect to network, then:

```
archinstall --config .system/archinstall-config.json
```

archinstall will still prompt to confirm the disk wipe/user credentials (none of
that is stored in the log — no passwords were ever logged) before it touches disk.
**Check `disk_config.device_modifications[0].device` in the JSON first** — it's
hardcoded to `/dev/nvme0n1`. If the replacement machine/drive enumerates
differently (e.g. a second NVMe present, or a different controller), edit that
field before running, or archinstall will target the wrong disk.

## Or: manual walkthrough of the guided menu

If you'd rather click through the TUI yourself, these are the same choices:

| Screen | Choice |
|---|---|
| Language | English |
| Mirrors | Region: United Kingdom (auto-selected list, all default) |
| Disk layout | Use a best-effort default layout, target `/dev/nvme0n1`, wipe |
| Filesystem | Btrfs, with subvolumes: `@`→`/`, `@home`→`/home`, `@log`→`/var/log`, `@pkg`→`/var/cache/pacman/pkg`; mount option `compress=zstd` |
| Boot partition | 1 GiB, FAT32, `/boot` |
| Bootloader | GRUB, with `removable` and `uki` (Unified Kernel Image) both enabled |
| Swap | Enabled, zram, zstd compression |
| Hostname | `archlinux` (never changed — rename here if you want something else this time) |
| Root password / user account | (not logged — set your own) |
| Kernel | `linux` (stock, not `linux-lts`/`linux-zen`) |
| Timezone | Europe/London |
| Locale | keyboard `us`, `en_US.UTF-8`, console font `default8x16` |
| Network | NetworkManager |
| NTP | On |
| Audio | pipewire |
| Bluetooth | Enabled |
| Additional packages | `dolphin firefox git hyprlock hyprpaper kitty neovim qt5-wayland qt6-wayland rofi slurp steam waybar wl-clipboard xdg-desktop-portal-gtk xdg-desktop-portal-hyprland zsh zsh-autocomplete zsh-syntax-highlighting grim` |
| Optional repositories | `multilib` (needed for Steam) |
| Profile | Desktop → Hyprland, seat access via `polkit` |
| Graphics driver | Nvidia (open kernel module, for Turing+ GPUs — matches the RTX 5080) |
| Display/login manager | sddm |

## After archinstall finishes

None of the Catppuccin theming, DaVinci Resolve, media apps (mpv/obs/yazi/etc.),
or AUR helper are part of this — archinstall only gets you to a bare Hyprland +
sddm desktop. From there, see the main `README.md` in this repo: install `yay`,
install packages from `.system/pacman-packages.txt` + `.system/aur-packages.txt`,
clone this repo to `~/Documents/dotfiles`, run `./install.sh`.
