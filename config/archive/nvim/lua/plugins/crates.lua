return {
  "Saecki/crates.nvim",
  event = { "BufRead Cargo.toml" },
  opts = {
    lsp = {
      enabled = true,
      actions = true,
      completion = true,
      hover = true,
    },
  },
  config = function(_, opts)
    local crates = require("crates")
    crates.setup(opts)
  end,
}
