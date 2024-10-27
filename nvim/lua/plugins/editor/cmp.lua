return {
  -- LuaSnip setup for manual loading

  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" }, -- Dependency for emoji completion
    opts = function(_, opts)
      -- Add emoji source
      table.insert(opts.sources, { name = "emoji" })

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter", -- Load LuaSnip only when entering Insert mode
    config = function()
      require("luasnip").setup({})
      require("luasnip.loaders.from_vscode").load() -- Load friendly-snippets
    end,
  },
  -- friendly-snippets dependency for LuaSnip
  {
    "rafamadriz/friendly-snippets",
    lazy = true, -- Keeps it from loading until manually called by LuaSnip
  },
}
