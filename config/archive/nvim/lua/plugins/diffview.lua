return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<CR>",        desc = "Diffview: Open" },
    { "<leader>gh", "<cmd>DiffviewFileHistory<CR>", desc = "Diffview: File History" },
    { "<leader>gc", "<cmd>DiffviewClose<CR>",       desc = "Diffview: Close" },
  },
  config = function()
    require("diffview").setup({})
  end,
}
