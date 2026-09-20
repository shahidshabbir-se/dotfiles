return {
  "lukas-reineke/indent-blankline.nvim",
  event = "VeryLazy",
  main = "ibl", -- required for v3
  opts = {
    indent = {
      char = "┊",
      tab_char = "┊",
    },
    exclude = {
      filetypes = {
        "dashboard",
        "alpha",
        "starter",
        "neo-tree",
        "lazy",
        "help",
        "terminal",
        "nofile",
      },
      buftypes = {
        "terminal",
        "nofile",
        "quickfix",
        "prompt",
      },
    },
  },
}
