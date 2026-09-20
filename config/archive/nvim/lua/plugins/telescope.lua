return {
  "nvim-telescope/telescope.nvim",

  dependencies = {
    "nvim-lua/plenary.nvim",

    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable "make" == 1
      end,
    },

    {
      "folke/snacks.nvim",
      opts = {
        image = {
          enabled = true,
        },
      },
    },
  },

  keys = {
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files()
      end,
      desc = "Find Files (Root Dir)",
    },

    {
      "<leader><leader>",
      function()
        require("telescope.builtin").find_files()
      end,
      desc = "Find Files (Root Dir)",
    },

    {
      "<leader>fi",
      function()
        local previewers = require "telescope.previewers"
        local pickers = require "telescope.builtin"

        local image_extensions = {
          png = true,
          jpg = true,
          jpeg = true,
          gif = true,
          webp = true,
          bmp = true,
          svg = true,
          avif = true,
          heic = true,
          tiff = true,
        }

        local image_previewer = previewers.new_buffer_previewer {
          title = "Image Preview",

          define_preview = function(self, entry)
            local path = entry.path or entry.value

            if not path then
              return
            end

            path = vim.fn.fnamemodify(path, ":p")

            if vim.fn.filereadable(path) ~= 1 then
              return
            end

            vim.schedule(function()
              if not vim.api.nvim_win_is_valid(self.state.winid) then
                return
              end

              local buf = self.state.bufnr

              if not vim.api.nvim_buf_is_valid(buf) then
                return
              end

              -- Snacks' image previewer uses the Kitty Graphics
              -- Protocol directly. Ghostty supports this protocol.
              Snacks.image.buf.attach(buf, {
                src = path,
              })
            end)
          end,

          teardown = function(self)
            pcall(function()
              Snacks.image.buf.detach(self.state.bufnr)
            end)
          end,
        }

        pickers.find_files {
          prompt_title = "Images",

          find_command = {
            "rg",
            "--files",
            "--hidden",
            "--glob",
            "!.git/*",
          },

          entry_maker = function(entry)
            local path = entry

            local extension = vim.fn.fnamemodify(path, ":e"):lower()

            if not image_extensions[extension] then
              return nil
            end

            return {
              value = path,
              ordinal = path,
              display = path,
              path = path,
            }
          end,

          previewer = image_previewer,
        }
      end,
      desc = "Find Images",
    },

    {
      "<leader>fg",
      "<cmd>Telescope live_grep<cr>",
      desc = "Live Grep",
    },

    {
      "<leader>fw",
      function()
        local word = vim.fn.expand "<cword>"

        require("telescope.builtin").grep_string {
          search = word,
          default_text = word,
          layout_strategy = "vertical",
          sorting_strategy = "ascending",
        }
      end,
      desc = "Search Word Under Cursor",
    },

    {
      "<leader>fb",
      "<cmd>Telescope buffers<cr>",
      desc = "Find Buffers",
    },

    {
      "<leader>fh",
      "<cmd>Telescope help_tags<cr>",
      desc = "Find Help",
    },

    {
      "<leader>fo",
      "<cmd>Telescope oldfiles<cr>",
      desc = "Find Recent Files",
    },
  },

  config = function()
    local telescope = require "telescope"
    local actions = require "telescope.actions"

    telescope.setup {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
        },

        prompt_prefix = "  ",
        selection_caret = " ",
        entry_prefix = "  ",

        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",

        layout_strategy = "horizontal",

        layout_config = {
          prompt_position = "top",
          height = 0.8,
          width = 0.75,

          horizontal = {
            preview_width = 0.55,
            mirror = false,
          },

          vertical = {
            mirror = true,
            preview_cutoff = 1,
            prompt_position = "top",
            height = 0.95,
            width = 0.6,
          },
        },

        file_sorter = require("telescope.sorters").get_fuzzy_file,
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,

        file_ignore_patterns = {
          "^%.git/",
        },

        path_display = {
          "truncate",
        },

        winblend = 0,

        borderchars = {
          "─",
          "│",
          "─",
          "│",
          "┌",
          "┐",
          "┘",
          "└",
        },

        color_devicons = true,
        use_less = true,

        set_env = {
          COLORTERM = "truecolor",
        },

        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,

        mappings = {
          i = {
            ["<C-h>"] = actions.preview_scrolling_left,
            ["<C-l>"] = actions.preview_scrolling_right,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },

          n = {
            ["<C-h>"] = actions.preview_scrolling_left,
            ["<C-l>"] = actions.preview_scrolling_right,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
        },
      },

      pickers = {
        find_files = {
          hidden = true,

          find_command = {
            "rg",
            "--files",
            "--hidden",
            "--glob",
            "!.git/*",
          },
        },
      },
    }

    pcall(telescope.load_extension, "fzf")
  end,
}
