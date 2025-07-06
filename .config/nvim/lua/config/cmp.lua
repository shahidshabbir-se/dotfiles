local cmp = require("cmp")
local lspkind = require("lspkind")

-- Merge codicons with custom icons
local icons = vim.tbl_extend("force", lspkind.presets.codicons, {
  Supermaven = "	",
  Copilot = "",
})

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered({
      border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }, -- correct order!
      side_padding = 0,
      col_offset = 0,
      max_width = 63,
      max_height = 7,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
    }),
    documentation = {
      border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }, -- square border
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      max_width = 60,
      max_height = 20,
    },
  },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  formatting = {
    format = function(entry, vim_item)
      -- Inject custom kinds based on source
      if entry.source.name == "copilot" then
        vim_item.kind = "Copilot"
      elseif entry.source.name == "supermaven" then
        vim_item.kind = "Supermaven"
      end

      local kind = vim_item.kind
      local icon = icons[kind] or ""

      vim_item.kind = icon .. " " .. kind
      vim_item.kind_hl_group = "CmpItemKind" .. kind
      vim_item.abbr_hl_group = "CmpItemAbbr"
      vim_item.menu_hl_group = "CmpItemMenu"

      return vim_item
    end,
  },
  sources = cmp.config.sources({
    { name = "luasnip" },
    { name = "nvim_lsp" },
    -- { name = "supermaven" },
    { name = "copilot", group_index = 2 },
  }, {
    { name = "buffer" },
  }),
})
