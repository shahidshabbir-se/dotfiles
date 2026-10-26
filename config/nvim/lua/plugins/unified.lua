return {
  "axkirillov/unified.nvim",
  cmd = "Unified",
  opts = {
    file_tree = {
      enabled = false,
    },
    auto_refresh = true,
    highlights = {
      add = "DiffAdd",
      delete = "DiffDelete",
      change = "DiffChange",
    },
  },
  keys = {
    {
      "<leader>gu",
      "<cmd>Unified HEAD<cr>",
      desc = "GitHub-style unified diff",
    },
  },
}
