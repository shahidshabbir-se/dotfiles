return {
  "echasnovski/mini.move",
  version = "*",
  config = function()
    require("mini.move").setup {
      mappings = {
        -- Visual mode
        left = "<M-Left>",
        right = "<M-Right>",
        down = "<M-Down>",
        up = "<M-Up>",

        -- Normal mode (line)
        line_left = "<M-Left>",
        line_right = "<M-Right>",
        line_down = "<M-Down>",
        line_up = "<M-Up>",
      },
      options = {
        reindent_linewise = true,
      },
    }
  end,
}
