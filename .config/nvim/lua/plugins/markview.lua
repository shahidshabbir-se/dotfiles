return {
  "OXY2DEV/markview.nvim",
  event = "VeryLazy",
  lazy = true,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = function(_, opts)
    local presets = require "markview.presets"

    ---@type markview.configuration
    local new_opts = {
      preview = {
        modes = { "i", "n", "v", "vs", "V", "Vs", "no", "c" },
        hybrid_modes = { "i" },
        callbacks = {
          on_enable = function(_, win)
            vim.wo[win].conceallevel = 2
            vim.wo[win].concealcursor = "nivc"
          end,
        },
      },
      markdown = {
        headings = presets.headings.arrowed,
        tables = {
          use_virt_lines = true,
        },
      },
      highlight_groups = "dynamic",
      checkboxes = presets.checkboxes.nerd,
      markdown_inline = {
        enable = true,
        tags = {
          enable = true,
          default = {
            conceal = true,
            hl = nil,
          },
        },
        entities = {
          enable = true,
          hl = nil,
        },
      },
      experimental = {
        check_rtp_message = false,
      },
    }

    opts = vim.tbl_deep_extend("force", new_opts, opts or {})
    return opts
  end,
}
