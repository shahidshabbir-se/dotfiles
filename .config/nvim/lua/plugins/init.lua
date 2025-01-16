return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua",
        "python",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "scss",
        "yaml",
        "nix",
        "markdown",
        "prisma",
        "markdown_inline",
      },
    },
  },

  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      require "configs.mason"
    end,
  },

  {
    "folke/which-key.nvim",
    config = function()
      local which_key = require "which-key"
      which_key.setup {
        preset = "helix",
      }
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "┊", tab_char = "┊" },
    },
  },

  {
    "echasnovski/mini.move",
    event = "VeryLazy",
    config = function()
      require "configs.mini-move"
    end,
  },

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "supermaven-inc/supermaven-nvim",
        opts = {},
      },
      {
        "L3MON4D3/LuaSnip",
        config = function(_, opts)
          require("luasnip").config.set_config(opts)

          local luasnip = require "luasnip"

          luasnip.filetype_extend("javascriptreact", { "html" })
          luasnip.filetype_extend("typescriptreact", { "html" })
          luasnip.filetype_extend("svelte", { "html" })

          require "nvchad.configs.luasnip"
        end,
      },

      {
        "hrsh7th/cmp-cmdline",
        event = "CmdlineEnter",
        config = function()
          local cmp = require "cmp"

          cmp.setup.cmdline("/", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = "buffer" } },
          })

          cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources(
              { { name = "path" } },
              { { name = "cmdline" } }
            ),
            matching = { disallow_symbol_nonprefix_matching = false },
          })
        end,
      },
    },

    opts = function(_, opts)
      table.insert(opts.sources, 1, { name = "supermaven" })
    end,
  },
}
