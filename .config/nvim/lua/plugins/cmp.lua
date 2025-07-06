return {
  {
    "hrsh7th/nvim-cmp",
    lazy = true,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "ray-x/cmp-treesitter",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      { "onsails/lspkind.nvim" },
      {
        "L3MON4D3/LuaSnip",
        wants = { "friendly-snippets", "vim-snippets" },
        config = function()
          require("config.cmp.luasnip").setup()
        end,
      },
      {
        "hrsh7th/cmp-cmdline",
        event = "CmdlineEnter",
        config = function()
          require(
            "config.cmp.cmdline")
        end
      },
      "rafamadriz/friendly-snippets",
      "honza/vim-snippets",
    },
    config = function()
      require("config.cmp")
    end,
  },
}
