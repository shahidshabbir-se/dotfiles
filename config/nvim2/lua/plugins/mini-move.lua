return {
  "echasnovski/mini.move",
  version = "*",
  config = function()
    require("mini.move").setup {
      mappings = {
        left       = "gh",
        right      = "gl",
        down       = "gj",
        up         = "gk",
        line_left  = "gh",
        line_right = "gl",
        line_down  = "gj",
        line_up    = "gk",
      },
      options = {
        reindent_linewise = true,
      },
    }
  end,
}
