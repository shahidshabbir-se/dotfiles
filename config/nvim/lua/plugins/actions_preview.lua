return {
  "aznhe21/actions-preview.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local preview = require("actions-preview")
    preview.setup({
      telescope = {
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
          width = 0.8,
          height = 0.9,
          prompt_position = "top",
          preview_cutoff = 20,
          preview_height = 0.5,
        },
      },
    })
  end,
  keys = {
    {
      "<leader>ca",
      function()
        require("actions-preview").code_actions()
      end,
      mode = { "n", "v" },
      desc = "LSP Code Actions (Visual Diff Preview)",
    },
  },
}
