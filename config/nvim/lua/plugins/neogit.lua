return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "echasnovski/mini.icons",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gs", "<cmd>Neogit<cr>", desc = "Neogit Status" },
    },
    opts = {
      disable_commit_confirmation = true,
      kind = "tab", -- Open neogit in a new tab for a clean focused view
      integrations = {
        diffview = true,
      },
    },
  },
}
