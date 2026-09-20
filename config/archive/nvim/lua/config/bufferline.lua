local bufferline = require("bufferline")

bufferline.setup({
  options = {
    mode = "buffers",
    numbers = "none",
    close_command = "bdelete! %d",
    right_mouse_command = "bdelete! %d",
    left_mouse_command = "buffer %d",
    indicator = { icon = "▎", style = "icon" },
    buffer_close_icon = "󰅖",
    modified_icon = "●",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",

    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(count, level)
      local icon = level:match("error") and " " or " "
      return " " .. icon .. count
    end,

    custom_filter = function(bufnr)
      local ft = vim.bo[bufnr].filetype
      return not vim.tbl_contains({ "alpha", "dashboard", "lazy", "neo-tree" }, ft)
    end,

    separator_style = "thin",
    always_show_bufferline = true,
    offsets = {
      {
        filetype = "neo-tree",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "left",
        separator = true,
      },
      {
        filetype = "NvimTree",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "left",
        separator = true,
      },
    },
  },
  highlights = {
    fill = {
      bg = "#1e1e2e", -- background behind bufferline
    },
    background = {
      fg = "#6c7086", -- dimmed foreground for inactive buffers
      bg = "#1e1e2e", -- background color for inactive buffers
    },
    buffer_selected = {
      fg = "#cdd6f4", -- normal bright text for active buffer
      bg = "#1e1e2e",
      bold = true,
      italic = false,
    },
    buffer_visible = {
      fg = "#a6adc8", -- visible but not active
      bg = "#1e1e2e",
    },
  },
  -- highlights = require("catppuccin.groups.integrations.bufferline").get(), -- optional
})
