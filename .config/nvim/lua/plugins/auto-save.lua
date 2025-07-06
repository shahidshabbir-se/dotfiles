return {
  "okuuva/auto-save.nvim",
  event = { "InsertLeave", "TextChanged" },
  opts = function()
    return require("config.auto-save")
  end,
}
