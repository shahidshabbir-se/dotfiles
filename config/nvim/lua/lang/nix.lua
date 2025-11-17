local M = {}

-- Treesitter parsers
M.treesitter = {
  "nix",
}

-- Mason servers / LSP binaries
M.mason = {
  "rnix",
}

-- LSP configuration for vim.lsp.enable
M.lsp = {
  ["rnix"] = {
    settings = {
      -- rnix-lsp doesn’t have tons of custom settings, default is fine
    },
  },
}

-- Formatters
M.formatters = {
  nix = { "nixpkgs-fmt" },
}

-- Linters
M.linters = {
  nix = { "nixpkgs-fmt" }, -- nixpkgs-fmt works as both linter and formatter
}

-- Tools to ensure installed via Mason
M.tools = {
  "nixpkgs-fmt",
}

return M
