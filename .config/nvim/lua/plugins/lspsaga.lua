return {
  'nvimdev/lspsaga.nvim',
  config = function()
    require('lspsaga').setup({
      ui = {
        border = "rounded",
      },
      code_action = {
        enable = false,
      },
      lightbulb = {
        enable = false,
        enable_in_insert = false,
        sign = false,
        virtual_text = false,
      },
      symbol_in_winbar = {
        enable = false,
      },
    })
  end,
  dependencies = {
    'nvim-treesitter/nvim-treesitter', -- optional
    'nvim-tree/nvim-web-devicons',     -- optional
  }
}
