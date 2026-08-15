# Palette — Claude Code dark accents on Catppuccin Mocha neutrals

The accent colours across this setup come from **Claude Code's built-in dark
theme**, not from Catppuccin. The neutrals (backgrounds, surfaces, greys, body
text) are still Catppuccin Mocha.

That split is deliberate rather than lazy: Claude Code defines **no background
colour at all** — it draws on whatever the terminal provides. So there is no
"Claude background" to copy, and Mocha's neutral ramp is what makes the accents
sit on something coherent.

## Where these values came from

Extracted from the theme object in the Claude Code binary itself
(`~/.local/share/claude/versions/<v>`), not eyedropped from a screenshot. The
dark theme is the object whose `text` is `rgb(255,255,255)`.

Eyedropping is actively misleading here: the "Tips for getting started" box
animates between `claude` (`#d77757`) and `claudeShimmer` (`#f59575`), so a
screenshot catches a blend that exists nowhere in the palette. An earlier pass
of this repo used `#e57e5a` for exactly that reason. If these need re-deriving
after an update:

```sh
grep -a -o -E '[A-Za-z_$]{2,6}=\{autoAccept:"rgb[^}]{0,4000}\}' \
    ~/.local/share/claude/versions/<version>
```

## Accent map

| Mocha slot | was      | now      | Claude Code source                  |
|------------|----------|----------|-------------------------------------|
| peach      | #fab387  | #d77757  | `claude` — the brand orange         |
| rosewater  | #f5e0dc  | #f59575  | `claudeShimmer`                     |
| flamingo   | #f2cdcd  | #f59575  | `claudeShimmer`                     |
| mauve      | #cba6f7  | #af87ff  | `autoAccept`                        |
| blue       | #89b4fa  | #b1b9f9  | `permission` / `suggestion`         |
| lavender   | #b4befe  | #b1b9f9  | `permission` / `suggestion`         |
| sapphire   | #74c7ec  | #6a9bcc  | `professionalBlue`                  |
| sky        | #89dceb  | #48968c  | `planMode`                          |
| teal       | #94e2d5  | #48968c  | `planMode`                          |
| green      | #a6e3a1  | #4eba65  | `success`                           |
| yellow     | #f9e2af  | #ffc107  | `warning`                           |
| red        | #f38ba8  | #ff6b80  | `error`                             |
| maroon     | #eba0ac  | #ff6b80  | `error`                             |
| pink       | #f5c2e7  | #fd5db1  | `bashBorder`                        |

`sapphire` uses `professionalBlue` rather than Claude's `ide` blue (`#4782c8`):
`ide` only reaches 4.1:1 against Mocha base, under the 4.5:1 line for text.
Every colour in the table above clears 4.8:1 on `#1e1e2e`.

## Neutrals — unchanged Catppuccin Mocha

| slot     | value   | | slot     | value   |
|----------|---------|-|----------|---------|
| text     | #cdd6f4 | | surface2 | #585b70 |
| subtext1 | #bac2de | | surface1 | #45475a |
| subtext0 | #a6adc8 | | surface0 | #313244 |
| overlay2 | #9399b2 | | base     | #1e1e2e |
| overlay1 | #7f849c | | mantle   | #181825 |
| overlay0 | #6c7086 | | crust    | #11111b |

Claude Code's own greys (`inactive #999999`, `promptBorder #888888`,
`subtle #505050`) are pure greys with no blue cast. They are deliberately *not*
used — mixing them into Mocha's slightly-blue neutral ramp reads as dirt.

Body text stays Mocha `#cdd6f4` rather than Claude's pure `#ffffff`, for the
same reason.

## Applied in

waybar, kitty, rofi, hyprland (borders), hyprlock, starship, zsh syntax
highlighting, fzf, yazi, neovim (catppuccin with `color_overrides`), fastfetch,
mpv OSC, OBS, dunst, and kdeglobals + `color-schemes/CatppuccinMochaMauve.colors`
for Qt/KDE apps.

Not applied in `icons/catppuccin-mocha-*-cursors/`: those SVGs are sources for
cursors already compiled to binary, and the active cursor theme is
`catppuccin-mocha-white`, so editing them changes nothing on screen.
