return {
  "akinsho/bufferline.nvim",
  event = { "BufReadPost", "BufNewFile" },
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
    local bufferline = require "bufferline"

    -- your mini palette table
    local C = {
      bg = "#1D1E29",
      fg = "#cdd6f4",
      fg_visible = "#a6adc8",
      fg_inactive = "#6c7086",
      offset_bg = "#16161E",
    }

    local function all_same_bg(bg)
      return {
        bg = bg,
      }
    end

    local function all_same_bg_bold(bg)
      return {
        bg = bg,
        bold = true,
      }
    end

    bufferline.setup {
      options = {
        mode = "buffers",
        numbers = "none",
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",

        indicator = { icon = " " },
        buffer_close_icon = "",
        modified_icon = "",
        close_icon = "",
        show_close_icon = false,
        left_trunc_marker = "",
        right_trunc_marker = "",

        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level)
          local icon = level:match "error" and " " or " "
          return " " .. icon .. count
        end,

        custom_filter = function(bufnr)
          local ft = vim.bo[bufnr].filetype
          return not vim.tbl_contains({
            "alpha",
            "dashboard",
            "lazy",
            "neo-tree",
            "NvimTree",
          }, ft)
        end,

        separator_style = "none",
        always_show_bufferline = true,

        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "BufferLineOffset",
            text_align = "left",
            separator = true,
          },
          {
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "BufferLineOffset",
            text_align = "left",
            separator = true,
          },
        },
      },

      highlights = {
        fill = { bg = C.bg },
        background = { fg = C.fg_inactive, bg = C.bg },
        buffer_selected = { fg = C.fg, bg = C.bg, bold = true },
        buffer_visible = { fg = C.fg_visible, bg = C.bg },
        indicator_selected = { bg = C.bg },

        offset_separator = { fg = C.offset_bg, bg = C.offset_bg },

        separator = { fg = C.fg_inactive, bg = C.bg },
        separator_selected = { fg = C.fg, bg = C.bg },

        duplicate = { bg = C.bg },
        duplicate_visible = { bg = C.bg },
        duplicate_selected = { fg = C.fg, bg = C.bg, bold = true },
        indicator_visible = { bg = C.bg },

        close_button = { fg = C.fg_inactive, bg = C.bg },
        close_button_visible = { fg = C.fg_visible, bg = C.bg },
        close_button_selected = { fg = C.fg, bg = C.bg },

        -- modified icons
        modified = all_same_bg(C.bg),
        modified_visible = all_same_bg(C.bg),
        modified_selected = all_same_bg(C.bg),

        -- WARNINGS
        warning = all_same_bg(C.bg),
        warning_visible = all_same_bg(C.bg),
        warning_selected = all_same_bg_bold(C.bg),

        warning_diagnostic = all_same_bg(C.bg),
        warning_diagnostic_visible = all_same_bg(C.bg),
        warning_diagnostic_selected = all_same_bg_bold(C.bg),

        -- ERRORS
        error = all_same_bg(C.bg),
        error_visible = all_same_bg(C.bg),
        error_selected = all_same_bg_bold(C.bg),

        error_diagnostic = all_same_bg(C.bg),
        error_diagnostic_visible = all_same_bg(C.bg),
        error_diagnostic_selected = all_same_bg_bold(C.bg),

        -- HINT
        hint = all_same_bg(C.bg),
        hint_visible = all_same_bg(C.bg),
        hint_selected = all_same_bg_bold(C.bg),

        hint_diagnostic = all_same_bg(C.bg),
        hint_diagnostic_visible = all_same_bg(C.bg),
        hint_diagnostic_selected = all_same_bg_bold(C.bg),

        -- INFO
        info = all_same_bg(C.bg),
        info_visible = all_same_bg(C.bg),
        info_selected = all_same_bg_bold(C.bg),

        info_diagnostic = all_same_bg(C.bg),
        info_diagnostic_visible = all_same_bg(C.bg),
        info_diagnostic_selected = all_same_bg_bold(C.bg),
      },
    }
  end,
}
