local M = {}

-- Treesitter parsers
M.treesitter = {
  "nix",
}

-- Mason servers / LSP binaries
M.mason = {
  "nil_ls",
}

-- LSP configuration for vim.lsp.enable
M.lsp = {
  ["nil_ls"] = {
    cmd = { "nil" },
    filetypes = { "nix" },
    root_markers = { "flake.nix", ".git" },
    settings = {
      ["nil"] = {
        formatting = {
          command = { "nixpkgs-fmt" },
        },
      },
    },
  },
}

-- Formatters
M.formatters = {
  -- nil_ls LSP handles formatting via nixpkgs-fmt (configured in LSP settings)
}

-- Linters
M.linters = {
  -- nil_ls LSP server provides diagnostics
}

-- Tools to ensure installed via Mason
M.tools = {
  "nixpkgs-fmt",
}

return M
