return {
  "echasnovski/mini.move",
  version = "*",
  config = function()
    require("mini.move").setup {
      mappings = {
 left = '<M-h>',
    right = '<M-l>',
    down = '<M-j>',
    up = '<M-k>',
      },
      options = {
        reindent_linewise = true,
      },
    }
  end,
}
