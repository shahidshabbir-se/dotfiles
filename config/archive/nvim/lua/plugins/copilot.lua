return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",

  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,

      debounce = 75,
      hide_during_completion = true,
      trigger_on_accept = true,

      keymap = {
        accept = "<Tab>",
        accept_word = false,
        accept_line = false,

        next = "<M-]>",
        prev = "<M-[>",

        dismiss = "<C-e>",
      },
    },

    panel = {
      enabled = false,
    },

    filetypes = {
      help = false,
      gitcommit = false,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      ["."] = false,
    },

    copilot_node_command = "node",

    server_opts_overrides = {},
  },
}
