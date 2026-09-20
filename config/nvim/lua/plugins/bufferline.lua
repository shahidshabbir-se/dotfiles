return {
  "akinsho/bufferline.nvim",
  version = "*",
  config = function()
    require("bufferline").setup({
      options = {
        separator_style = { "", "" },

        indicator = {
          style = "none",
        },

        show_tab_indicators = false,

        show_buffer_close_icons = true,

        hover = {
          enabled = true,
          delay = 0,
          reveal = { "close" },
        },

        buffer_close_icon = "󰅖",

        offsets = {
          {
            filetype = "neo-tree",
            text = "󰉋 File Explorer",
            highlight = "Directory",
            text_align = "left",
            separator = true,
          },
        },
      },
    })
  end,
}
