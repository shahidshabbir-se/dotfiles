return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "onsails/lspkind.nvim",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "f3fora/cmp-spell",
    },
    -- config = config,
    config = function(_, opts)
      local cmp = require("cmp")
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
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

      cmp.setup({
        window = {
          completion = {
            border = "rounded",
            winhighlight = "Normal:MyHighlight",
            winblend = 0,
            scrollbar = false,
          },
          documentation = {
            border = "rounded",
            winhighlight = "Normal:MyHighlight",
            winblend = 0,
          },
        },
      })

      cmp.setup(opts)
    end,
  },
  {
    "rafamadriz/friendly-snippets",
    lazy = true,
    config = function()
      require("luasnip").filetype_extend("javascriptreact", { "html" })
      require("luasnip").filetype_extend("typescriptreact", { "html" })

      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
