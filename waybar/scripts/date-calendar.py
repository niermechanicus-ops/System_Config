#!/usr/bin/env python3
# Date box + hover calendar for waybar. Replaces clock#date, whose built-in
# {calendar} tooltip can only colour things, not lay them out.
#
#   date-calendar.py            print the bar JSON (date text + calendar tooltip)
#   date-calendar.py shift N    move the shown month by N, then refresh the bar
#
# The tooltip is drawn in Departure Mono, so the grid lines, stars and the
# today block are all on the font's pixel grid. Scrolling flips months; the
# offset forgets itself after RESET seconds, so the next hover is back on
# the current month.
import calendar, datetime, json, os, subprocess, sys, time

STATE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "waybar-calendar.offset")
RESET = 60
SIGNAL = 10   # matches "signal" for custom/date in config.jsonc

CREAM, PAST, DIM = "#f5e0dc", "#a59fb8", "#5c5675"
PEACH, YELLOW, PINK, FLAMINGO, RULE = "#f59575", "#f9e2af", "#f5c2e7", "#f2cdcd", "#4a4462"
W = 28   # 7 columns x 4 chars


def c(colour, text):
    return f"<span color='{colour}'>{text}</span>"


def read_offset():
    try:
        off, at = open(STATE).read().split()
        return int(off) if time.time() - float(at) < RESET else 0
    except (OSError, ValueError):
        return 0


if len(sys.argv) == 3 and sys.argv[1] == "shift":
    off = read_offset() + int(sys.argv[2])   # read before "w" truncates it
    with open(STATE, "w") as f:
        f.write(f"{off} {time.time()}")
    subprocess.run(["pkill", f"-RTMIN+{SIGNAL}", "-x", "waybar"])
    sys.exit()

today = datetime.date.today()
m = today.month - 1 + read_offset()
year, month = today.year + m // 12, m % 12 + 1

title = f"{calendar.month_name[month].upper()} {year}"
head = c(YELLOW, "★") + " " + c(PEACH, title) + " " + c(YELLOW, "★")
pad = W - len(title) - 6
arrows_l, arrows_r = c(DIM, "←"), c(DIM, "→")
lines = [arrows_l + " " * (pad // 2) + head + " " * (pad - pad // 2) + arrows_r,
         c(RULE, "━" * W),
         "".join(c(FLAMINGO if i >= 5 else YELLOW, f"{d:>3} ")
                 for i, d in enumerate(["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]))]

for week in calendar.Calendar(firstweekday=0).monthdatescalendar(year, month):
    row = ""
    for i, d in enumerate(week):
        cell = f"{d.day:>3} "
        if d == today:
            # A solid pink block with the number cut out of it, the same
            # treatment as the active workspace tile on the bar.
            row += f"<span background='{PINK}' color='#1e1e2e'>{cell}</span>"
        elif d.month != month:
            row += c(DIM, cell)
        elif d < today:
            row += c(PAST, cell)
        else:
            row += c(FLAMINGO if i >= 5 else CREAM, cell)
    lines.append(row)

lines.append(c(RULE, "━" * W))
if (year, month) == (today.year, today.month):
    week_no = today.isocalendar().week
    day_no = today.timetuple().tm_yday
    days = 366 if calendar.isleap(today.year) else 365
    foot = f"week {week_no} · day {day_no} of {days}"
else:
    foot = "scroll back to today"
lines.append(c(DIM, foot.center(W)))

print(json.dumps({
    "text": today.strftime("%A, %B %d"),
    # No <tt>: it would swap Departure Mono (already monospace) for the
    # generic monospace font and lose the pixel lettering.
    "tooltip": "\n".join(lines),
}, ensure_ascii=False))
