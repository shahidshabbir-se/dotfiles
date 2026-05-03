return {
  "folke/todo-comments.nvim",
  cmd = { "TodoTrouble", "TodoTelescope" },
  event = "BufReadPost",
  opts = {
    keywords = {
      FIX = {
        icon = " ",
        color = "error",
        alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
      },
      TODO = { icon = " ", color = "info" },
      HACK = { icon = " ", color = "warning" },
      WARN = { icon = " ", color = "warning", alt = { "WARNING" } },
      PERF = { icon = "󰓅 ", alt = { "OPTIMIZE", "PERFORMANCE", "EFFICIENCY" } },
      NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
      INFO = { icon = " ", color = "hint" },
      PATH = { icon = " ", color = "#7aa2f7", alt = { "LINK", "ROUTE", "FS" } },
    },
  },
  -- stylua: ignore
  keys = {
    { "]t",         function() require("todo-comments").jump_next() end,              desc = "Next Todo Comment" },
    { "[t",         function() require("todo-comments").jump_prev() end,              desc = "Previous Todo Comment" },
    { "<leader>xt", "<cmd>Trouble todo toggle<cr>",                                   desc = "Todo (Trouble)" },
    { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
    { "<leader>st", "<cmd>TodoTelescope<cr>",                                         desc = "Todo" },
    { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",                 desc = "Todo/Fix/Fixme" },
  },
}
