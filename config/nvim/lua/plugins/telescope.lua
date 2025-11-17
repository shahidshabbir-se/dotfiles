return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    opts = vim.tbl_deep_extend("force", opts, {
      defaults = {
        file_ignore_patterns = { "node_modules" },
        mappings = {
          i = {
            ["<C-j>"] = require("telescope.actions").move_selection_next,
            ["<C-k>"] = require("telescope.actions").move_selection_previous,
            ["<C-h>"] = require("telescope.actions.layout").toggle_preview,
          },
          n = {
            ["<C-h>"] = require("telescope.actions.layout").toggle_preview,
          },
        },
        borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      },
    })
    return opts
  end,
}
