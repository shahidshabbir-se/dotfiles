return {
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-cmdline",
    },
    opts = function(_, opts)
      local cmp = require("cmp")

      opts = opts or require("nvchad.configs.cmp")

      -- Enforce single borders for completion and documentation windows
      opts.window = {
        completion = cmp.config.window.bordered({
          border = "single",
          winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None,FloatBorder:CmpBorder",
        }),
        documentation = cmp.config.window.bordered({
          border = "single",
          winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder",
        }),
      }

      -- ':' command-line mode completion
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })

      -- '/' search mode completion
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      return opts
    end,
  },
}
