return {
  -- Overrides
  { import = "plugins.override.telescope" },
  { import = "plugins.override.blankline" },
  { import = "plugins.override.nvim-web-devicons" },
  { import = "plugins.override.nvim-tree" },
  { import = "plugins.override.conform" },

  -- Specs
  { import = "plugins.spec.tiny-code-action" },
  { import = "plugins.spec.ts-autotag" },
  { import = "plugins.spec.mini-indentoscope" },
  { import = "plugins.spec.copilot" },
  { import = "plugins.spec.vim-astro" },
  { import = "plugins.spec.markview" },
  { import = "plugins.spec.debugging" },
  { import = "plugins.spec.treesitter" },
  { import = "plugins.spec.auto-save" },
  { import = "plugins.spec.auto-session" },
  { import = "plugins.spec.mini-animate" },
  { import = "plugins.spec.nvim-cmp" },
  -- { import = "plugins.spec.noice" },
  { import = "plugins.spec.trouble" },
  { import = "plugins.spec.undo-tree" },
  { import = "plugins.spec.vim-visual-multi" },
  { import = "plugins.spec.cloak" },
  { import = "plugins.spec.sql" },
  -- { import = "plugins.spec.snacks" },

  -- Plugins
  { import = "plugins.local.js-playground" },

  -- LSP & Mason
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
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

  -- Editor Enhancements
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
    "echasnovski/mini.move",
    event = "VeryLazy",
    config = function()
      require "configs.mini-move"
    end,
  },

  -- UI Enhancements
  {
    "razak17/tailwind-fold.nvim",
    ft = { "html", "svelte", "astro", "vue", "typescriptreact" },
    opts = {
      min_chars = 40,
    },
  },
  {
    "chikko80/error-lens.nvim",
    event = "LspAttach",
    opts = {},
  },
  {
    "folke/todo-comments.nvim",
    event = "BufReadPre",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- Linting & Formatting
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        dockerfile = { "hadolint" },
      },
      linters = {
        sqlfluff = {
          args = {
            "lint",
            "--format=json",
            "--dialect=postgres",
          },
        },
      },
    },
  },

  -- Typing Speed Enhancement
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
  },
}
