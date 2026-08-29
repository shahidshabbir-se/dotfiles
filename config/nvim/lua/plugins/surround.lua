return {
  "echasnovski/mini.surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("mini.surround").setup({
      mappings = {
        add = "gsa",            -- Add surrounding
        delete = "gsd",         -- Delete surrounding
        find = "gsf",           -- Find right surrounding
        find_left = "gsF",      -- Find left surrounding
        highlight = "gsh",      -- Highlight surrounding
        replace = "gsr",        -- Replace surrounding
        update_n_lines = "gsn", -- Update n_lines
      },
    })
  end,
}
