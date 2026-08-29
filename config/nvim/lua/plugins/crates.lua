return {
  "Saecki/crates.nvim",
  event = { "BufRead Cargo.toml" },
  opts = {
    completion = {
      cmp = {
        enabled = true,
      },
    },
  },
  config = function(_, opts)
    local crates = require("crates")
    crates.setup(opts)
  end,
}
