-- Colorscheme: Catppuccin Mocha neutrals, Claude Code dark accents.
--
-- See PALETTE.md at the root of this repo for where these values come from and
-- why the neutrals stay Catppuccin. Keep this table in sync with it.
--
-- Neovim was silently on LazyVim's default (tokyonight) before this file
-- existed — lua/plugins/example.lua looks like it selects gruvbox, but its
-- third line is `if true then return {} end`, so nothing in it ever loads.
-- catppuccin was already installed as a LazyVim optional plugin; this pins it
-- as the active scheme and recolours it rather than adding a new dependency.

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      background = { dark = "mocha" },
      transparent_background = false,
      -- Only the accent slots are overridden. Every neutral (base, mantle,
      -- crust, surface0-2, overlay0-2, subtext0-1, text) is left at its
      -- Catppuccin value, because Claude Code defines no background colour of
      -- its own and its greys are flat neutrals that muddy Mocha's ramp.
      color_overrides = {
        mocha = {
          rosewater = "#f59575", -- claudeShimmer
          flamingo = "#f59575", -- claudeShimmer
          pink = "#fd5db1", -- bashBorder
          mauve = "#af87ff", -- autoAccept
          red = "#ff6b80", -- error
          maroon = "#ff6b80", -- error
          peach = "#d77757", -- claude
          yellow = "#ffc107", -- warning
          green = "#4eba65", -- success
          teal = "#48968c", -- planMode
          sky = "#48968c", -- planMode
          sapphire = "#6a9bcc", -- professionalBlue
          blue = "#b1b9f9", -- permission / suggestion
          lavender = "#b1b9f9", -- permission / suggestion
        },
      },
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        indent_blankline = { enabled = true },
        lsp_trouble = true,
        mason = true,
        native_lsp = { enabled = true },
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        which_key = true,
      },
      custom_highlights = function(c)
        return {
          -- Diffs follow Claude Code's own diff colours rather than
          -- Catppuccin's green/red tints, so a diff in nvim and a diff in the
          -- terminal read the same.
          DiffAdd = { bg = "#225c2b" }, -- diffAdded
          DiffDelete = { bg = "#7a2936" }, -- diffRemoved
          DiffText = { bg = "#38a660", fg = c.base }, -- diffAddedWord
        }
      end,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
