return {
  'nvimdev/lspsaga.nvim',
  event = "InsertEnter",
  config = function()
    require('lspsaga').setup({
      code_action = {
        enable = true,
      },
      lightbulb = {
        enable = true,
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
