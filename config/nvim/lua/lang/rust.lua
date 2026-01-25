local M = {}

M.treesitter = {
  "rust",
  "toml",
}

M.mason = {
  "rust_analyzer",
}

M.tools = {
  "codelldb",
}

-- Rustaceanvim handles LSP, formatting, and linting (via clippy) automatically.
-- We don't need to add them to none-ls here to avoid conflicts.
M.formatters = {}
M.linters = {}

return M
