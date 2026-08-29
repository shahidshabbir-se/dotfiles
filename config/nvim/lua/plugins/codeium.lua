return {
  "Exafunction/codeium.nvim",
  event = "InsertEnter",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  config = function()
    require("codeium").setup({
      enable_chat = true,
      virtual_text = {
        enabled = true,
        manual = false,
        filetypes = {},
        default_filetype_enabled = true,
        idle_delay = 75,
        key_bindings = {
          accept = "<C-f>",         -- Ctrl-f or Tab to accept full multi-line block
          accept_word = "<C-w>",    -- Ctrl-w to accept next word
          accept_line = "<C-l>",    -- Ctrl-l to accept next line
          clear = "<C-e>",          -- Ctrl-e to dismiss suggestion
          next = "<C-n>",           -- Ctrl-n for next multi-line suggestion
          prev = "<C-p>",           -- Ctrl-p for prev multi-line suggestion
        },
      },
    })
  end,
}
