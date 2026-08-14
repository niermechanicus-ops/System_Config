-- Catppuccin Mocha
local base       = 0xff1e1e2e
local surface0   = 0xff313244
local text       = 0xffcdd6f4
local mauve      = 0xffcba6f7
local rosewater  = 0xfff5e0dc

swayimg.text.color = text
swayimg.text.background = base
swayimg.text.shadow = base

swayimg.viewer.mark_color = mauve
swayimg.viewer.set_window_background(base)

swayimg.gallery.window_color = base
swayimg.gallery.selected_color = mauve
swayimg.gallery.unselected_color = surface0
swayimg.gallery.border_color = rosewater
swayimg.gallery.mark_color = mauve

swayimg.slideshow.set_window_background(base)
