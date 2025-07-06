local treesitter = require("nvim-treesitter.configs")
local go = require("lang.go")
local templ = require("lang.templ")

treesitter.setup({
  highlight = { enable = true },
  indent = { enable = true },
  ensure_installed = vim.tbl_flatten({
    {
      "json",
      "javascript",
      "typescript",
      "tsx",
      "yaml",
      "html",
      "css",
      "prisma",
      "markdown",
      "markdown_inline",
      "svelte",
      "graphql",
      "bash",
      "lua",
      "vim",
      "dockerfile",
      -- "python",
      -- "rust",
      -- "ron",
      "gitignore",
      "query",
      "nix",
      "json5",
      "sql",
    },
    go.treesitter,
    templ.treesitter
  }),
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-space>",
      node_incremental = "<C-space>",
      node_decremental = "<bs>",
    },
  },
})
