return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live Grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Help Tags" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>",   desc = "Recent Files" },
    -- Compact floating buffer switcher
    {
      "<leader>h",
      function()
        require("telescope.builtin").buffers(
          require("telescope.themes").get_dropdown({
            previewer             = false,
            sort_mru              = true,
            ignore_current_buffer = false,
            prompt_title          = "  Open Buffers",
            layout_config         = { width = 0.5, height = 0.5 },
            -- Rounded borderchars (commented):
            -- borderchars           = {
            --   prompt  = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
            --   results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
            --   preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            -- },
            borderchars           = {
              prompt  = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
              results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
              preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
            },
          })
        )
      end,
      desc = "Buffer switcher (dropdown)",
    },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        prompt_prefix = "   ",
        selection_caret = " ❯ ",
        entry_prefix = "   ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        path_display = { "filename_first" },
        file_ignore_patterns = { "^%.git/", "node_modules/", "target/", "%.lock" },
        buffer_previewer_maker = function(filepath, bufnr, opts)
          opts = opts or {}
          filepath = vim.fn.expand(filepath)
          vim.loop.fs_stat(filepath, function(_, stat)
            if stat and stat.size > 100000 then
              return
            else
              require("telescope.previewers").buffer_previewer_maker(filepath, bufnr, opts)
            end
          end)
        end,
        -- Rounded borderchars (commented):
        -- borderchars = {
        --   prompt = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        --   results = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        --   preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        -- },
        borderchars = {
          prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-n>"] = actions.move_selection_next,
            ["<C-p>"] = actions.move_selection_previous,
            ["<C-h>"] = actions.preview_scrolling_left,
            ["<C-l>"] = actions.preview_scrolling_right,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<esc>"] = actions.close,
          },
          n = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["q"] = actions.close,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
        },
        live_grep = {
          only_sort_text = true,
        },
        buffers = {
          sort_mru              = true,
          ignore_current_buffer = true,
          show_all_buffers      = true,
        },
      },
    })

    pcall(telescope.load_extension, "fzf")
  end,
}
