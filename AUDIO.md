# Audio

Hardware, routing, and the one non-obvious workaround this machine needs to make
DaVinci Resolve record.

## The chain

```
mic ──XLR──> Cloudlifter ──XLR──> Scarlett 2i2 4th Gen ──USB──> PipeWire ──> apps
             (+25 dB, eats                (card 0,
              the 48V, mic                 preamp gain
              never sees it)               0-69 dB)
```

The Cloudlifter is powered by the interface's 48V phantom and consumes it rather
than passing it through, so 48V must stay **on** for the Cloudlifter to work and
the microphone downstream of it never sees phantom. That is what makes the
arrangement safe for a dynamic or ribbon mic.

Because of the +25 dB the Cloudlifter contributes, interface gain wants to sit
*lower* than it would for a bare mic — around 40 dB on input 1 is roughly 65 dB
effective, not 40.

### Devices

| Card | Device | Role |
|------|--------|------|
| 0 | Scarlett 2i2 4th Gen | default **source** (mic) |
| 3 | Logitech A50 X | default **sink** (headset) |
| 1 | GB203 (RTX 5080) HDMI | — |
| 2 | HD-Audio Generic | — |
| 4 | Generic USB Audio | — |

The Scarlett runs on PipeWire's **Pro Audio** profile, which exposes its channels
raw as `capture_AUX0..3` rather than as a pre-mixed stereo pair. `capture_AUX0` is
analogue input 1.

The interface's own routing matrix is set so input 1 reaches the computer on USB
channel 1: `PCM 01 <- DSP 1 <- Analogue 1`. If a channel ever goes missing in a
DAW, check that matrix (in `alsa-scarlett-gui`) before suspecting the OS — it is
device-side state that survives reboots and is invisible to PipeWire.

## The Resolve fix — `asoundrc`

**DaVinci Resolve's Fairlight input does not work through the PipeWire ALSA
plugin.** `~/.asoundrc` (symlinked from `asoundrc` in this repo) exists solely to
work around that, by routing ALSA's `default` PCM through the PulseAudio plugin
instead. Audio still ends up in PipeWire — `pipewire-pulse` serves that path. The
only thing that changes is which plugin an ALSA-native application loads on its
way there: `libasound_module_pcm_pulse.so` rather than
`libasound_module_pcm_pipewire.so`.

### How the failure presents

Silently, which is what makes it expensive to diagnose. Nothing errors:

- the capture stream negotiates cleanly (F32LE, 8ch, 48 kHz)
- WirePlumber links it to the microphone
- `pw-top` shows the node running with no xruns
- Resolve's log shows recording starting and stopping normally

and yet the Fairlight input meter never moves, and a voiceover take lands on the
timeline with the right name, the right length and the right format with **every
sample exactly 0**.

### Why it can't be fixed inside Resolve

Fairlight is pinned to whatever ALSA calls `default`. Its only usable I/O engine
on Linux is "System Audio" — the other entry, Desktop Video, needs Blackmagic
hardware — and under it the **Input device** row in
*Preferences > System > Video and Audio I/O* is static text reading `Default`,
not a picker. There is no in-application setting that repoints it, so the fix has
to change what `default` means.

### Why nothing underneath was at fault

Capturing from the same `default` PCM, with the same format and channel count
Resolve negotiates, puts the microphone on channel 1 where it belongs — through
either plugin:

```
arecord -D default -f FLOAT_LE -c 8 -r 48000   ->  ch1 -53 dBFS, ch2-8 silent
arecord -D pulse   -f FLOAT_LE -c 8 -r 48000   ->  ch1 -48 dBFS, ch2-8 silent
```

So the ALSA layer delivers correctly either way. The difference is entirely in
how Resolve's audio engine behaves against the two plugins.

### Why `~/.asoundrc` and not the packaged fix

The advice found in the wild is to install `pulseaudio-alsa`, which drops a
`99-pulseaudio-default.conf` into `/etc/alsa/conf.d` and displaces
`pipewire-alsa`'s. **That package no longer exists on Arch.** Its config moved
into `alsa-plugins`, which ships the file to `/usr/share/alsa/alsa.conf.d` but
never symlinks it into `/etc/alsa/conf.d` — so on a current install,
`pipewire-alsa`'s `99-pipewire-default.conf` is the only definition of `default`
on the system and nothing competes with it.

`~/.asoundrc` is read *after* `/etc/alsa/conf.d`, so it wins without removing
`pipewire-alsa` (which `pipewire-jack` and a long dependency tree sit behind) and
without a package update quietly reverting the change.

### Applying and undoing

Resolve reads ALSA configuration **only at startup** — it must be fully quit and
reopened, not just have the project reloaded. To undo the workaround entirely,
delete `~/.asoundrc`; nothing else depends on it.

Verify which plugin is live at any time:

```
$ amixer -D default info | head -2
Card default 'pulse'/'PulseAudio'      # fixed
Card default 'pipewire'/'PipeWire'     # unfixed — Resolve will record silence
```

## Recording voiceover in Resolve

Assuming the above is in place:

1. Fairlight page, **Patch Input/Output**: source `Audio Inputs`, patch
   `1: ALSA` to the target track's input. Channel 1 is the microphone; channels
   2-8 exist in the panel but carry nothing.
2. **Arm the track** — the `R` button on its mixer strip, lit red. Without it the
   meter stays dead and `Record Track: Auto` has no track to write to.
3. Record Voiceover's own **Audio Input** dropdown stays on `Default`; it has
   nothing else to offer and does not need one.
4. Watch the meter before committing to a take. Aim for peaks around -12 to -6
   dBFS, set with the **interface** preamp (via `alsa-scarlett-gui`), not with a
   fader in Resolve — that is real analogue gain ahead of the converter, rather
   than amplification of an already-quiet recording.

## Waybar controls

The top bar carries the audio controls, defined in `waybar/config.jsonc`:

| Chip | Action | Opens |
|------|--------|-------|
| volume `󰕾` | left-click | mute toggle |
| volume `󰕾` | **right-click** | `pavucontrol` |
| volume `󰕾` | scroll | volume ±5% |
| Scarlett `󰍬` | left-click | `alsa-scarlett-gui` |

The `󰍬` chip is driven by `waybar/scripts/scarlett.sh`. It reports the live state
of the interface on hover — per-input gain in dB, Line/Inst, Air, phantom power,
direct monitor — read from the scarlett2 driver's ALSA control elements **by
name**, never by numid, since numids are assigned in driver registration order and
move between kernel and device-firmware versions.

The chip is drawn only while a Focusrite interface is present: the script emits
empty text otherwise, which makes waybar hide the module rather than leave a
button that opens an empty panel.

Both panels get Hyprland rules in `hypr/hyprland.lua` (`pavucontrol-float`,
`scarlett-gui-float`) so they float, centre and stay on DP-3 — `pavucontrol` tiles
by default and takes half a 4K screen.

## Packages this relies on

`pipewire`, `pipewire-pulse`, `pipewire-alsa`, `wireplumber`, `alsa-plugins`
(provides `libasound_module_pcm_pulse.so` — the workaround needs it),
`pavucontrol`, `alsa-scarlett-gui`, `qpwgraph`.

The scarlett2 driver is in-kernel; no firmware or DKMS module is needed for the
2i2 4th Gen. Confirm it is live by checking that the gain controls exist:

```
amixer -c 0 controls | grep 'Gain Capture Volume'
```

If that comes back empty the driver has not attached its mixer and
`alsa-scarlett-gui` will have nothing to show.
