return {
  -- Treesitter parser for EWW's yuck language
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "yuck" },
    },
  },

  -- Yuck syntax plugin (provides syntax highlighting fallback + indent)
  {
    "elkowar/yuck.vim",
    ft = "yuck",
  },
}
