---@type NvPluginSpec
return {
  "folke/trouble.nvim",
  opts = {},
  cmd = "Trouble",
  keys = {
    {
      "<leader>td",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Toggle Diagnostics (Trouble)",
    },
    {
      "<leader>tb",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Toggle Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>ts",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Toggle Symbols (Trouble)",
    },
    {
      "<leader>tr",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "Toggle LSP References/Definitions (Trouble)",
    },
    {
      "<leader>tl",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Toggle Location List (Trouble)",
    },
    {
      "<leader>tq",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Toggle Quickfix List (Trouble)",
    },
  },
}
