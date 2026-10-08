#!/usr/bin/env python3
"""Colour-wheel picker for the waybar RGB chip (left-click).

Hue runs around the wheel and saturation from the centre (white) out to the
rim; the slider underneath is brightness. Apply hands the hex to rgb-set,
which saves it and repaints the chip. Enter applies, Escape closes.

The hardware takes a few seconds to change (OpenRGB re-detects every device
on each call), so nothing is sent while dragging -- only on Apply.
"""
import colorsys
import math
import os
import subprocess
import sys

import cairo
import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Gdk", "4.0")
from gi.repository import Gdk, Gtk  # noqa: E402

STATE_DIR = os.path.join(
    os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")), "rgb"
)
RGB_SET = os.path.expanduser("~/.local/bin/rgb-set")
WHEEL = 300  # px

# Catppuccin Mocha
CSS = b"""
window { background: #1e1e2e; color: #cdd6f4; }
.swatch { border-radius: 10px; min-height: 34px; border: 1px solid #45475a; }
entry { background: #313244; color: #cdd6f4; border: none; font-family: monospace; }
button { background: #313244; color: #cdd6f4; border: none; padding: 6px 14px; }
button:hover { background: #45475a; }
button.apply { background: #cba6f7; color: #1e1e2e; font-weight: bold; }
button.apply:hover { background: #b4befe; }
scale trough { background: #313244; min-height: 8px; border-radius: 4px; }
scale highlight { background: #cba6f7; border-radius: 4px; }
"""


def read_state(name, default):
    try:
        with open(os.path.join(STATE_DIR, name)) as f:
            value = f.read().strip()
        return value if len(value) == 6 else default
    except OSError:
        return default


def hex_to_hsv(hex_):
    r, g, b = (int(hex_[i : i + 2], 16) / 255 for i in (0, 2, 4))
    return colorsys.rgb_to_hsv(r, g, b)


class Picker(Gtk.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app, title="RGB colour")
        self.set_resizable(False)

        current = read_state("color", "FF3000")
        if current == "000000":  # off: start from the colour it was before
            current = read_state("last", "FF3000")
        self.h, self.s, self.v = hex_to_hsv(current)
        if self.v == 0:
            self.v = 1.0

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        for side in ("top", "bottom", "start", "end"):
            getattr(box, f"set_margin_{side}")(16)
        self.set_child(box)

        self.wheel = Gtk.DrawingArea(content_width=WHEEL, content_height=WHEEL)
        self.wheel.set_draw_func(self.draw_wheel)
        self.wheel_surface = self.render_wheel()
        drag = Gtk.GestureDrag()
        drag.connect("drag-begin", lambda g, x, y: self.pick(x, y))
        drag.connect("drag-update", self.on_drag)
        self.wheel.add_controller(drag)
        box.append(self.wheel)

        self.brightness = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        self.brightness.set_draw_value(False)
        self.brightness.set_value(self.v * 100)
        self.brightness.connect("value-changed", self.on_brightness)
        row = Gtk.Box(spacing=8)
        row.append(Gtk.Label(label="󰃠"))
        self.brightness.set_hexpand(True)
        row.append(self.brightness)
        box.append(row)

        row = Gtk.Box(spacing=8)
        self.swatch = Gtk.DrawingArea(hexpand=True)
        self.swatch.add_css_class("swatch")
        self.swatch.set_draw_func(self.draw_swatch)
        row.append(self.swatch)
        self.entry = Gtk.Entry(max_length=7, width_chars=8)
        self.entry.connect("activate", self.on_entry)
        row.append(self.entry)
        box.append(row)

        row = Gtk.Box(spacing=8, homogeneous=True)
        off = Gtk.Button(label="Off")
        off.connect("clicked", lambda *_: self.apply("000000"))
        apply = Gtk.Button(label="Apply")
        apply.add_css_class("apply")
        apply.connect("clicked", lambda *_: self.apply(self.hex()))
        row.append(off)
        row.append(apply)
        box.append(row)
        self.set_default_widget(apply)

        keys = Gtk.EventControllerKey()
        keys.connect("key-pressed", self.on_key)
        self.add_controller(keys)

        self.refresh()

    # -- colour state -------------------------------------------------------

    def hex(self):
        r, g, b = colorsys.hsv_to_rgb(self.h, self.s, self.v)
        return "%02X%02X%02X" % (round(r * 255), round(g * 255), round(b * 255))

    def refresh(self, from_entry=False):
        if not from_entry:
            self.entry.set_text("#" + self.hex())
        self.wheel.queue_draw()
        self.swatch.queue_draw()

    # -- wheel --------------------------------------------------------------

    def render_wheel(self):
        """Hue/saturation disc at full brightness, drawn once."""
        size, r = WHEEL, WHEEL / 2
        surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, size, size)
        stride = surf.get_stride()
        data = bytearray(stride * size)
        for y in range(size):
            dy = y + 0.5 - r
            for x in range(size):
                dx = x + 0.5 - r
                dist = math.hypot(dx, dy)
                if dist > r:
                    continue
                hue = (math.atan2(-dy, dx) / (2 * math.pi)) % 1
                cr, cg, cb = colorsys.hsv_to_rgb(hue, min(dist / (r - 1), 1), 1)
                a = min(1.0, r - dist)  # 1px anti-aliased rim
                i = y * stride + x * 4
                # ARGB32 is native-endian, i.e. B G R A in memory; premultiplied
                data[i : i + 4] = bytes(
                    (round(cb * 255 * a), round(cg * 255 * a), round(cr * 255 * a), round(a * 255))
                )
        surf.get_data()[:] = data
        surf.mark_dirty()
        return surf

    def draw_wheel(self, area, cr, w, h):
        r = WHEEL / 2
        cr.set_source_surface(self.wheel_surface, 0, 0)
        cr.paint()
        # darken the whole disc by the brightness slider so it previews V
        cr.arc(r, r, r, 0, 2 * math.pi)
        cr.set_source_rgba(0, 0, 0, 1 - self.v)
        cr.fill()
        # marker
        ang = self.h * 2 * math.pi
        mx, my = r + math.cos(ang) * self.s * (r - 1), r - math.sin(ang) * self.s * (r - 1)
        cr.arc(mx, my, 8, 0, 2 * math.pi)
        cr.set_source_rgb(*colorsys.hsv_to_rgb(self.h, self.s, self.v))
        cr.fill_preserve()
        cr.set_line_width(3)
        cr.set_source_rgb(1, 1, 1)
        cr.stroke_preserve()
        cr.set_line_width(1)
        cr.set_source_rgb(0, 0, 0)
        cr.stroke()

    def pick(self, x, y):
        r = WHEEL / 2
        dx, dy = x - r, y - r
        self.h = (math.atan2(-dy, dx) / (2 * math.pi)) % 1
        self.s = min(math.hypot(dx, dy) / (r - 1), 1)
        if self.v < 0.05:  # picking a hue at zero brightness would do nothing
            self.v = 1.0
            self.brightness.set_value(100)
        self.refresh()

    def on_drag(self, gesture, ox, oy):
        ok, sx, sy = gesture.get_start_point()
        self.pick(sx + ox, sy + oy)

    def on_brightness(self, scale):
        self.v = scale.get_value() / 100
        self.refresh()

    def draw_swatch(self, area, cr, w, h):
        cr.set_source_rgb(*colorsys.hsv_to_rgb(self.h, self.s, self.v))
        cr.paint()

    def on_entry(self, entry):
        text = entry.get_text().strip().lstrip("#")
        if len(text) == 6 and all(c in "0123456789abcdefABCDEF" for c in text):
            self.h, self.s, self.v = hex_to_hsv(text)
            self.brightness.set_value(self.v * 100)
            self.refresh()
            self.apply(text.upper())

    def on_key(self, ctrl, keyval, code, state):
        if keyval == Gdk.KEY_Escape:
            self.close()
            return True
        return False

    def apply(self, hex_):
        subprocess.Popen(
            ["setsid", "-f", RGB_SET, hex_],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        self.close()


def main():
    app = Gtk.Application(application_id="dev.nier.rgbwheel")

    def activate(app):
        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        win = app.get_active_window() or Picker(app)
        win.present()

    app.connect("activate", activate)
    return app.run(sys.argv[:1])


if __name__ == "__main__":
    sys.exit(main())
