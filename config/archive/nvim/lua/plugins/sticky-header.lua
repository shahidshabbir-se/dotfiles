return {
  "nvim-treesitter/nvim-treesitter-context",
  opts = {
    enable = true,        -- Enable this plugin (Can be enabled/disabled later via commands)
    max_lines = 1,        -- How many lines the window should span. Defaults to infinite.
    trim_scope = "outer", -- Which context lines to discard if max_lines is exceeded.
    mode = "cursor",      -- Line used to calculate context. Choices: 'cursor', 'topline'
    zindex = 20,          -- The Z-index of the context window
  }
}
