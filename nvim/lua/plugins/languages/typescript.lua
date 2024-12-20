local keymaps = {
  toggle = "<leader>cbd", -- default '<leader>dd'
  go_to_definition = "<leader>cbx", -- default '<leader>dx'
}

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.vtsls.settings.typescript = {}
      opts.servers.eslint = {
        settings = {
          workingDirectories = { mode = "auto" },
        },
      }
    end,
  },
  {
    "OlegGulevskyy/better-ts-errors.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    keys = {
      keymaps.toggle,
      keymaps.go_to_definition,
    },
    opts = {
      keymaps = keymaps,
    },
  },
}
