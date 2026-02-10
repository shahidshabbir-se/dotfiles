return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = function()
    return {
      style = "moon", -- options: "storm", "moon", "night", "day"
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "transparent",
        floats = "transparent",
      },
      sidebars = { "qf", "help", "nvimtree", "lualine", "packer" },
      hide_inactive_statusline = true,
      dim_inactive = false,
      lualine_bold = true,
      on_highlights = function(hl)
        hl.WinSeparator = {
          fg = "#3b4261",
        }
        hl.NvimTreeWinSeparator = {
          fg = "#3b4261",
        }
      end,
    }
  end,
}
