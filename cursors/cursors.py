# Pixel-art cursor shapes, one character per pixel on a 16x16 grid.
#   W fill (text)   B blue accent   R red   g dark glass   O outline (crust)
#   . transparent
# You only draw the fill: build.py adds the crust outline all round
# (8-neighbour) automatically. Write an explicit O only for lines *inside* a
# shape, such as the gaps between fingers.
# Hotspot is (x, y) in grid pixels: the exact point that clicks.
#
# Names listed in EDGE_OUTLINE get a 4-neighbour outline instead, for shapes
# whose parts sit so close that diagonal outlines would merge them.
EDGE_OUTLINE = {"move"}

ARROW = [
    "W.........",
    "WW........",
    "WWW.......",
    "WWWW......",
    "WWWWW.....",
    "WWWWWW....",
    "WWWWWWW...",
    "WWWWWWWW..",
    "WWWWWWWWW.",
    "WWWWWW....",
    "WWW.WWW...",
    "WW..WWW...",
    "W....WWW..",
    ".....WWW..",
]

HAND = [
    "...WW.........",
    "...WW.........",
    "...WW.........",
    "...WWOWW......",
    "...WWOWWOWW...",
    "...WWOWWOWWOWW",
    "WW.WWOWWOWWOWW",
    "WWWWWWWWWWWWWW",
    ".WWWWWWWWWWWWW",
    "..WWWWWWWWWWWW",
    "..WWWWWWWWWWW.",
    "...WWWWWWWWWW.",
    "....WWWWWWWW..",
]

IBEAM = [
    "WWW.WWW",
    "...W...",
    "...W...",
    "...W...",
    "...W...",
    "...W...",
    "...W...",
    "...W...",
    "...W...",
    "...W...",
    "...W...",
    "WWW.WWW",
]

NS = [
    "...W...",
    "..WWW..",
    ".WWWWW.",
    "WWWWWWW",
    "...W...",
    "...W...",
    "...W...",
    "...W...",
    "...W...",
    "WWWWWWW",
    ".WWWWW.",
    "..WWW..",
    "...W...",
]

NWSE = [
    "WWWWW.......",
    "WWWW........",
    "WWW.........",
    "WW.W........",
    "W...W.......",
    ".....W......",
    "......W.....",
    ".......W...W",
    "........W.WW",
    ".........WWW",
    "........WWWW",
    ".......WWWWW",
]

CROSS = [
    ".....W.....",
    ".....W.....",
    ".....W.....",
    ".....W.....",
    "...........",
    "WWWW.B.WWWW",
    "...........",
    ".....W.....",
    ".....W.....",
    ".....W.....",
    ".....W.....",
]

NOT_ALLOWED = [
    "....RRRRR....",
    "..RRRRRRRRR..",
    ".RRR.....RRR.",
    ".RR.....RRRR.",
    "RR.....RRR.RR",
    "RR....RRR..RR",
    "RR...RRR...RR",
    "RR..RRR....RR",
    "RR.RRR.....RR",
    ".RRRR.....RR.",
    ".RRR.....RRR.",
    "..RRRRRRRRR..",
    "....RRRRR....",
]

def hourglass(level):
    """Hourglass frame: level 0 = all sand on top ... 4 = all sand at bottom.
    The top bulb drains from its wide end; the bottom fills from its wide end;
    while sand is moving, the neck shows a falling stream."""
    top = [".ggggggg.", "..ggggg..", "...ggg...", "....g...."]
    bot = ["....g....", "...ggg...", "..ggggg..", ".ggggggg."]
    moving = 0 < level < 4
    rows = ["BBBBBBBBB"]
    for i, r in enumerate(top):
        full = i >= level or (i == 3 and moving)
        rows.append(r.replace("g", "W") if full else r)
    for i, r in enumerate(bot):
        full = i >= 4 - level or (i == 0 and moving)
        rows.append(r.replace("g", "W") if full else r)
    rows.append("BBBBBBBBB")
    return rows

# name -> (frames, hotspot, ms per frame); frames are lists of rows
CURSORS = {
    "default":     ([ARROW], (0, 0), 0),
    "pointer":     ([HAND], (3, 0), 0),
    "text":        ([IBEAM], (3, 6), 0),
    "ns-resize":   ([NS], (3, 6), 0),
    "ew-resize":   ([["".join(r[i] for r in NS) for i in range(len(NS[0]))]], (6, 3), 0),
    "nwse-resize": ([NWSE], (6, 6), 0),
    "nesw-resize": ([[r[::-1] for r in NWSE]], (5, 6), 0),
    "crosshair":   ([CROSS], (5, 5), 0),
    "not-allowed": ([NOT_ALLOWED], (6, 6), 0),
    "wait":        ([hourglass(l) for l in range(5)], (4, 5), 220),
}

CURSORS["move"] = ([[
    ".....W.....",
    "....WWW....",
    "...WWWWW...",
    ".....W.....",
    "..W..W..W..",
    ".WW..W..WW.",
    "WWWWWWWWWWW",
    ".WW..W..WW.",
    "..W..W..W..",
    ".....W.....",
    "...WWWWW...",
    "....WWW....",
    ".....W.....",
]], (5, 6), 0)

# progress: the arrow with a small hourglass tucked under it ("busy, but
# you can still click"), flipping between full-top and full-bottom.
def _progress(level):
    g = [list(r.ljust(14, ".")) for r in ARROW]
    small = ["BBBBB", ".WWW.", "..W..", ".ggg.", "BBBBB"] if level == 0 else \
            ["BBBBB", ".ggg.", "..W..", ".WWW.", "BBBBB"]
    for y, r in enumerate(small):
        for x, c in enumerate(r):
            g[9 + y][9 + x] = c
    return ["".join(r) for r in g]
CURSORS["progress"] = ([_progress(0), _progress(1)], (0, 0), 450)

# Every name apps ask for -> which cursor above draws it. Anything not here
# falls through to the Inherits theme in index.theme.
ALIASES = {
    "default": ["left_ptr", "arrow", "top_left_arrow", "context-menu", "help",
                "question_arrow", "whats_this", "copy", "alias", "dnd-copy",
                "dnd-link", "dnd-ask", "dnd-none", "vertical-text", "cell",
                "plus", "zoom-in", "zoom-out"],
    "pointer": ["hand", "hand1", "hand2", "pointing_hand", "grab", "openhand",
                "grabbing", "closedhand", "dnd-move", "fleur-hand"],
    "text": ["xterm", "ibeam"],
    "ns-resize": ["sb_v_double_arrow", "v_double_arrow", "n-resize", "s-resize",
                  "top_side", "bottom_side", "row-resize", "size_ver", "split_v"],
    "ew-resize": ["sb_h_double_arrow", "h_double_arrow", "e-resize", "w-resize",
                  "left_side", "right_side", "col-resize", "size_hor", "split_h"],
    "nwse-resize": ["nw-resize", "se-resize", "top_left_corner",
                    "bottom_right_corner", "size_fdiag", "bd_double_arrow"],
    "nesw-resize": ["ne-resize", "sw-resize", "top_right_corner",
                    "bottom_left_corner", "size_bdiag", "fd_double_arrow"],
    "crosshair": ["cross", "tcross", "cross_reverse", "diamond_cross", "target"],
    "not-allowed": ["crossed_circle", "no-drop", "forbidden", "circle",
                    "pirate", "X_cursor"],
    "wait": ["watch"],
    "progress": ["left_ptr_watch", "half-busy"],
    "move": ["fleur", "all-scroll", "size_all"],
}
