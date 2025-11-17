return {
  "magicduck/grug-far.nvim",
  opts = { headermaxwidth = 80 },
cmd="GrugFar",
  keys = {
    {
      "<leader>sr",
      function()
        local grug = require "grug-far"
        local ext = vim.bo.buftype == "" and vim.fn.expand "%:e"
        grug.open {
          transient = true,
          prefills = {
            filesfilter = ext and ext ~= "" and "*." .. ext or nil,
          },
        }
      end,
      mode = { "n", "v" },
      desc = "search and replace",
    },
  },
}
