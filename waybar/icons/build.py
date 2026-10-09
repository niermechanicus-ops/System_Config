#!/usr/bin/env python3
# Builds PixelBarIcons.ttf from the grids in icons.py.
#
#   python3 build.py        (then restart waybar; new glyphs need a restart,
#                            a SIGUSR2 style reload won't pick them up)
#
# Metrics are copied from Departure Mono so mixing the two never changes the
# line height: 550 units/em, 50 units per pixel (so 22px text = 2 screen px
# per icon pixel), ascent 550, descent 150, caps 8px tall.
import os
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen
from icons import ICONS

PX, UPM, ASC, DESC = 50, 550, 550, 150
here = os.path.dirname(os.path.abspath(__file__))

def glyph(rows):
    pen = TTGlyphPen(None)
    for r, row in enumerate(rows):
        y0 = (7 - r) * PX              # row 7 sits on the baseline
        c = 0
        while c < len(row):            # one rectangle per horizontal run
            if row[c] != "#":
                c += 1; continue
            start = c
            while c < len(row) and row[c] == "#":
                c += 1
            x0, x1, y1 = start * PX, c * PX, y0 + PX
            pen.moveTo((x0, y0)); pen.lineTo((x0, y1))   # clockwise = filled
            pen.lineTo((x1, y1)); pen.lineTo((x1, y0)); pen.closePath()
    return pen.glyph()

order, cmap, glyphs, metrics = [".notdef"], {}, {".notdef": TTGlyphPen(None).glyph()}, {".notdef": (PX * 7, 0)}
for name, (cp, rows) in ICONS.items():
    g = "icon_" + name.replace("-", "_")
    order.append(g); cmap[cp] = g; glyphs[g] = glyph(rows)
    metrics[g] = ((max(len(r) for r in rows) + 1) * PX, 0)   # 1px right bearing

fb = FontBuilder(UPM, isTTF=True)
fb.setupGlyphOrder(order)
fb.setupCharacterMap(cmap)
fb.setupGlyf(glyphs)
fb.setupHorizontalMetrics(metrics)
fb.setupHorizontalHeader(ascent=ASC, descent=-DESC)
fb.setupNameTable({"familyName": "PixelBar Icons", "styleName": "Regular"})
fb.setupOS2(sTypoAscender=ASC, sTypoDescender=-DESC, sTypoLineGap=0,
            usWinAscent=ASC, usWinDescent=DESC, sCapHeight=8 * PX)
fb.setupPost()
out = os.path.join(here, "PixelBarIcons.ttf")
# Write a new file and rename it over the old one, never rewrite in place:
# programs that already have the font open (waybar, rofi) map the file, and
# rewriting the same file under them leaves their cached glyph widths out of
# step with the new data, which collapsed the gap after every bar icon
# (2026-10-09). A rename gives the new font a fresh inode instead.
tmp = out + ".tmp"
fb.save(tmp)
os.replace(tmp, out)
os.system("fc-cache -f ~/.local/share/fonts")
print("wrote", out, "- now restart waybar: pkill -x waybar; setsid -f waybar")
