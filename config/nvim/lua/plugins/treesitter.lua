return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  opts = {
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
    autotag = { enable = true },
    ensure_installed = {
      "bash",
      "c",
      "css",
      "dockerfile",
      "html",
      "javascript",
      "json",
      "jsonc",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "nix",
      "prisma",
      "query",
      "rust",
      "ron",
      "scss",
      "sql",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    },
  },
  config = function(_, opts)
    local ok, configs = pcall(require, "nvim-treesitter.configs")
    if ok then
      configs.setup(opts)
    end
  end,
}
