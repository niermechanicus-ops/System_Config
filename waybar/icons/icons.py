# Pixel-art icons for the bar, one character per font pixel ('#' = ink).
# Drawn on Departure Mono's grid: 8 rows = its cap height, so an icon sits
# exactly as tall as the digits beside it. Rows run top to bottom; a 9th row
# hangs one pixel below the baseline.
#
# Codepoints are in Supplementary Private Use Area-B (U+100000+), which no
# Nerd Font touches, so these can never collide with a glyph Departure Mono
# already has.

ICONS = {
    # CPU usage: a chip with pins on all four sides
    "cpu": (0x100000, [
        "..#.#.#..",
        ".#######.",
        "##.....##",
        ".#.###.#.",
        "##.###.##",
        ".#.###.#.",
        "##.....##",
        ".#######.",
        "..#.#.#..",   # 9th row: the bottom pins hang below the baseline
    ]),
    # GPU usage: a graphics card, two fans, PCIe fingers underneath
    "gpu": (0x100001, [
        "###########",
        "#.........#",
        "#.###.###.#",
        "#.#.#.#.#.#",
        "#.###.###.#",
        "#.........#",
        "###########",
        ".#.#.#.#...",
    ]),
    # CPU temp: thermometer + a pixel C
    "cpu-temp": (0x100002, [
        ".###.....",
        ".#.#.....",
        ".#.#.....",
        ".###..###",
        ".###..#..",
        "#####.#..",
        "#####.#..",
        ".###..###",
    ]),
    # GPU temp: thermometer + a pixel G
    "gpu-temp": (0x100003, [
        ".###.....",
        ".#.#.....",
        ".#.#.....",
        ".###..###",
        ".###..#..",
        "#####.#.#",
        "#####.#.#",
        ".###..###",
    ]),
    # Volume: speaker + 0/1/2 waves, and muted
    "vol-low": (0x100004, [
        "...#......",
        "..##......",
        "####......",
        "####.#....",
        "####.#....",
        "####......",
        "..##......",
        "...#......",
    ]),
    "vol-mid": (0x100005, [
        "...#......",
        "..##..#...",
        "####...#..",
        "####.#.#..",
        "####.#.#..",
        "####...#..",
        "..##..#...",
        "...#......",
    ]),
    "vol-high": (0x100006, [
        "...#....#.",
        "..##..#..#",
        "####...#.#",
        "####.#.#.#",
        "####.#.#.#",
        "####...#.#",
        "..##..#..#",
        "...#....#.",
    ]),
    "vol-mute": (0x100007, [
        "...#......",
        "..##......",
        "####.#..#.",
        "####..##..",
        "####..##..",
        "####.#..#.",
        "..##......",
        "...#......",
    ]),
    # RGB: a cut gem (facet lines are left as gaps), drawn in the LED colour
    "rgb": (0x100008, [
        "..#####..",
        ".##.#.##.",
        "#########",
        ".###.###.",
        "..##.##..",
        "...#.#...",
        "....#....",
        ".........",
    ]),
    # Network: a little monitor with a signal dot, for the ONLINE chip
    "net": (0x100009, [
        "#########",
        "#.......#",
        "#...#...#",
        "#..###..#",
        "#.......#",
        "#########",
        "...###...",
        ".#######.",
    ]),
}
