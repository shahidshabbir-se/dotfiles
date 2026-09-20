return {
  "folke/todo-comments.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    signs = true,
  },
  keys = {
    { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
    { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Search TODO Comments" },
    { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "TODOs (Trouble)" },
  },
}
