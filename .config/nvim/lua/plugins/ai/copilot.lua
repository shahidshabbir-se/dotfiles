return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    build = ":Copilot auth",
    opts = {
      suggestion = {
        enabled = false,
        auto_trigger = true,
        hide_during_completion = false,
        keymap = {
          accept = "<C-f>",  -- Accept suggestion (VS Code-like)
          next = "<M-]>",    -- Next suggestion
          prev = "<M-[>",    -- Previous suggestion
          dismiss = "<C-x>", -- Dismiss suggestion
        },
      },
      panel = {
        enabled = false, -- Disable Copilot Panel (optional)
      },
      filetypes = {
        markdown = true,
        help = true,
        lua = true,
        javascript = true,
        typescript = true,
        python = true,
        astro = true,
        tsx = true,
        jsx = true,
        go = true,
        yml = true,
        yaml = true,
        svelte = true,
        templ = true,
      },
    },
  },
  { 'AndreM222/copilot-lualine' },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end
  },
}
