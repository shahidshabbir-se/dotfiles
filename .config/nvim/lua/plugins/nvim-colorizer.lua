return {
  "NvChad/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    filetypes = {
      "*", -- Enable for all filetypes
      css = { names = true },
      html = { names = true },
      javascript = { names = true },
      lua = { names = true },
    },
    user_default_options = {
      RGB = true,          -- #RGB hex codes
      RRGGBB = true,       -- #RRGGBB hex codes
      names = false,       -- "blue", "red", etc.
      RRGGBBAA = true,     -- #RRGGBBAA hex codes
      rgb_fn = true,       -- CSS rgb() and rgba()
      hsl_fn = true,       -- CSS hsl() and hsla()
      mode = "background", -- foreground | background | virtualtext
      tailwind = true,     -- Tailwind colors
      always_update = false,
    },
  },
  config = function(_, opts)
    require("colorizer").setup(opts.filetypes, opts.user_default_options)
  end,
}
