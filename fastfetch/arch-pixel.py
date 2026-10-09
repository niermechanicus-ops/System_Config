#!/usr/bin/env python3
"""Draws arch-pixel.png, the pixel-art Arch logo fastfetch shows in kitty.

Run from anywhere: python3 arch-pixel.py (needs python-pillow).

Each sprite pixel is 14x14 screen px. Kitty's cell with Departure Mono at
22px is 14x28, so one sprite pixel is exactly one cell wide and half a cell
tall: the 24x24 sprite fills 24x12 cells with no resampling, and stays as
crisp as the font. Change kitty's font size and PX must change with it.

Shape follows the real logo rather than a plain "A": the notch in the left
edge, the rounded arch cut into the base, the feet tapering to points, and
the right leg a little heavier than the left.

H = shimmer highlight (left edge, as if lit from the left), O = Claude
orange, the same two oranges as the bar's clock and fastfetch's keys.
"""
from pathlib import Path
from PIL import Image

PX = 14
COLOURS = {"H": (0xf5, 0x95, 0x75, 255), "O": (0xd7, 0x77, 0x57, 255)}
SPRITE = """
...........HH...........
...........HO...........
..........HOOO..........
..........HOOO..........
.........HOOOOO.........
.........HOOOOO.........
........HHOOOOOO........
........HOOOOOOO........
.......HHOOOOOOOO.......
.......HOOOOOOOOO.......
.......HHOOOOOOOOO......
........HOOOOOOOOO......
.....HHHOOOOOOOOOOO.....
.....HOOOOOOOOOOOOO.....
....HHOOOOO..OOOOOOO....
....HOOOOO....OOOOOO....
...HHOOOO......OOOOOO...
...HOOOO........OOOOO...
..HHOOO..........OOOOO..
..HOOO............OOOO..
.HHOO..............OOOO.
.HOO................OOO.
HHO..................OOO
HO....................OO
""".split()

assert all(len(row) == len(SPRITE[0]) for row in SPRITE), "ragged sprite"
w, h = len(SPRITE[0]), len(SPRITE)
img = Image.new("RGBA", (w * PX, h * PX), (0, 0, 0, 0))
for y, row in enumerate(SPRITE):
    for x, c in enumerate(row):
        if c in COLOURS:
            img.paste(COLOURS[c], (x * PX, y * PX, (x + 1) * PX, (y + 1) * PX))
out = Path(__file__).with_name("arch-pixel.png")
img.save(out)
print(f"{out}: {w}x{h} sprite, {img.width}x{img.height}px, "
      f"{img.width // 14}x{img.height // 28} kitty cells")
