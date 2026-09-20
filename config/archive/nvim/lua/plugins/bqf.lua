return {
  "kevinhwang91/nvim-bqf",
  ft = "qf",
  dependencies = {
    "junegunn/fzf",
  },
  opts = {
    auto_enable = true,
    preview = {
      win_height = 12,
      win_vheight = 12,
      delay_syntax = 80,
      border = "rounded",
    },
  },
}
