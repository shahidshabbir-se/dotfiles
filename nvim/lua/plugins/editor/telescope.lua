return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope", -- Lazy-load on command
  dependencies = { "nvim-lua/plenary.nvim" }, -- Add required dependencies
  config = function()
    require("telescope").setup({})
  end,
}
