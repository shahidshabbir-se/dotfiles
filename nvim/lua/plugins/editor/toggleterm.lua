return {
  "akinsho/toggleterm.nvim",
  event = "VeryLazy",
  config = function()
    require("toggleterm").setup({
      size = 20,
      open_mapping = [[<A-t>]],
      direction = "horizontal",
      shell = "/bin/zsh",
      float_opts = {
        border = "rounded",
      },
    })
  end,
}
