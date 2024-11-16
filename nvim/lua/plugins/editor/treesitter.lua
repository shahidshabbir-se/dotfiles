return {
  "nvim-treesitter/nvim-treesitter",
  -- event = "BufReadPost", -- Load on buffer read
  config = function()
    require("nvim-treesitter.configs").setup({
      highlight = {
        enable = true,
      },
    })
  end,
}
