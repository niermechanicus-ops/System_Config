#!/usr/bin/env python3
# Builds the "pixel-mocha" XCursor theme from the grids in cursors.py.
#
#   python3 build.py      then:  hyprctl setcursor pixel-mocha 24
#   PREVIEW=preview.png python3 build.py   also redraws the preview sheet
#
# Writes ../icons/pixel-mocha-cursors (symlinked into ~/.local/share/icons).
# Each design pixel becomes a 2x2 block at size 24 (so the cursor shares the
# bar's 2px pixel grid), 3x3 at 36 and 4x4 at 48 — integer scales only, so
# no size is ever blurred. No xcursorgen needed; the file format is written
# directly below.
import os, struct, shutil
from cursors import CURSORS, ALIASES, EDGE_OUTLINE

PAL = {  # Catppuccin Mocha, as used on the bar
    "W": 0xFFCDD6F4,  # text
    "O": 0xFF11111B,  # crust outline
    "B": 0xFFB1B9F9,  # bar blue
    "R": 0xFFFF6B80,  # bar red
    "g": 0xFF45475A,  # surface1, empty glass
}
SIZES = {24: 2, 36: 3, 48: 4}   # nominal size -> pixel scale
GRID = 16

here = os.path.dirname(os.path.abspath(__file__))
theme = os.path.join(here, "..", "icons", "pixel-mocha-cursors")

def outlined(rows, edge=False):
    """Pad by 1 and wrap every drawn pixel in crust (8-neighbour, or
    4-neighbour when edge=True)."""
    near = [(-1, 0), (1, 0), (0, -1), (0, 1)] if edge else \
           [(dy, dx) for dy in (-1, 0, 1) for dx in (-1, 0, 1)]
    h, w = len(rows) + 2, max(len(r) for r in rows) + 2
    g = [["."] * w for _ in range(h)]
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            g[y + 1][x + 1] = c
    out = [row[:] for row in g]
    for y in range(h):
        for x in range(w):
            if g[y][x] == ".":
                if any(0 <= y+dy < h and 0 <= x+dx < w and g[y+dy][x+dx] not in ".O"
                       for dy, dx in near):
                    out[y][x] = "O"
    return out

def image(grid, scale):
    size = GRID * scale
    px = [0] * (size * size)
    for y, row in enumerate(grid):
        for x, c in enumerate(row):
            if c == "." or x >= GRID or y >= GRID:
                continue
            for dy in range(scale):
                for dx in range(scale):
                    px[(y*scale + dy) * size + x*scale + dx] = PAL[c]
    return size, px

def xcursor(frames, hot, delay, edge=False):
    chunks = []
    for nominal, scale in SIZES.items():
        for f in frames:
            size, px = image(outlined(f, edge), scale)
            # +1 because outlined() padded the grid by one pixel
            hx, hy = (hot[0] + 1) * scale + scale // 2, (hot[1] + 1) * scale + scale // 2
            head = struct.pack("<IIIIIIIII", 36, 0xFFFD0002, nominal, 1,
                               size, size, hx, hy, delay)
            chunks.append((nominal, head + struct.pack("<%dI" % len(px), *px)))
    ntoc = len(chunks)
    pos = 16 + ntoc * 12
    toc, body = b"", b""
    for nominal, data in chunks:
        toc += struct.pack("<III", 0xFFFD0002, nominal, pos)
        pos += len(data); body += data
    return b"Xcur" + struct.pack("<III", 16, 0x10000, ntoc) + toc + body

if os.path.isdir(theme):
    shutil.rmtree(theme)
os.makedirs(os.path.join(theme, "cursors"))
with open(os.path.join(theme, "index.theme"), "w") as f:
    f.write("[Icon Theme]\nName=pixel-mocha\nComment=Pixel-art cursors, Catppuccin Mocha\n"
            "Inherits=catppuccin-mocha-white\n")
cdir = os.path.join(theme, "cursors")
for name, (frames, hot, delay) in CURSORS.items():
    with open(os.path.join(cdir, name), "wb") as f:
        f.write(xcursor(frames, hot, delay, name in EDGE_OUTLINE))
    for alias in ALIASES.get(name, []):
        os.symlink(name, os.path.join(cdir, alias))
print("wrote", os.path.normpath(theme), "-", len(CURSORS), "cursors,",
      sum(len(v) for v in ALIASES.values()), "aliases")

if __name__ == "__main__" and os.environ.get("PREVIEW"):
    from PIL import Image
    tiles = [outlined(f, n in EDGE_OUTLINE) for n, (fr, _, _) in CURSORS.items() for f in fr]
    S = 8
    out = Image.new("RGB", (len(tiles) * (18 * S), 18 * S), (88, 91, 112))
    for i, t in enumerate(tiles):
        for y, row in enumerate(t):
            for x, c in enumerate(row):
                if c != ".":
                    v = PAL[c]
                    for dy in range(S):
                        for dx in range(S):
                            out.putpixel((i*18*S + S + x*S + dx, S + y*S + dy),
                                         ((v >> 16) & 255, (v >> 8) & 255, v & 255))
    out.save(os.environ["PREVIEW"])
