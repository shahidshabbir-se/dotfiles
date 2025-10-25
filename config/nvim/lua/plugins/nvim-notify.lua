return {
  "rcarriga/nvim-notify",
  lazy = false,
  priority = 1000, -- Load early to override default notify
  config = function()
    local notify = require("notify")

    vim.notify = notify

    notify.setup({
      -- 👇 Tweak to your liking
      stages = "slide", -- "fade", "slide", "fade_in_slide_out", "static"
      timeout = 2000,
      background_colour = "NONE",
      minimum_width = 30,
      icons = {
        ERROR = "",
        WARN  = "",
        INFO  = "",
        DEBUG = "",
        TRACE = "✎",
      },
      render = "simple", -- or "minimal", "simple", "wrapped-compact"
    })
  end,
}
