local dashboard = require("dashboard")

dashboard.setup({
  theme = 'hyper',
  disable_move = false,
  shortcut_type = 'letter',
  shuffle = false,
  change_to_vcs_root = false,

  config = {
    header = {
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                     ]],
      [[       ████ ██████           █████      ██                     ]],
      [[      ███████████             █████                             ]],
      [[      █████████ ███████████████████ ███   ███████████   ]],
      [[     █████████  ███    █████████████ █████ ██████████████   ]],
      [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
      [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
      [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
      [[                                                                       ]],
    },

    shortcut = {},

    packages = { enable = true },
    project = { enable = true },
    mru = { enable = true },

  },

  hide = {
    statusline = true,
    tabline = true,
    winbar = true,
  },
})
