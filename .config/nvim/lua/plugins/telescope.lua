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
  opts = function(_, opts)
    local map = vim.keymap.set
    local entry_display = require("telescope.pickers.entry_display")
    local make_entry = require("telescope.make_entry")
    local strings = require("plenary.strings")
    local utils = require("telescope.utils")
    local icon_width = 2
    local SIZES = {
      HEIGHT = 0.8,
      WIDTH = 0.7,
      PREVIEW_WIDTH = 0.5,
    }

    local get_path_and_tail = function(file_name)
      local tail = utils.path_tail(file_name)
      local truncated_path = strings.truncate(file_name, #file_name - #tail, "")
      local path = utils.transform_path({ path_display = { "truncate" } }, truncated_path)
      return tail, path
    end

    local files = function(filetype, extra_opts)
      local files_opts = {
        previewer = true,
        layout_config = {
          horizontal = {
            width = SIZES.WIDTH,
            height = SIZES.HEIGHT,
            preview_width = SIZES.PREVIEW_WIDTH,
          },
          mirror = false,
        },
      }
      local oldfiles_opts = {
        previewer = true,
        layout_config = {
          prompt_position = "top",
          width = SIZES.WIDTH,
          height = SIZES.HEIGHT,
          preview_width = SIZES.PREVIEW_WIDTH,
          mirror = true,
          preview_cutoff = 0,
        },
      }
      local picker_data = filetype == "find"
          and { picker = "find_files", options = vim.tbl_deep_extend("force", files_opts, extra_opts or {}) }
          or filetype == "old"
          and { picker = "oldfiles", options = vim.tbl_deep_extend("force", oldfiles_opts, extra_opts or {}) }
      if not picker_data then return end
      local base_entry_maker = make_entry.gen_from_file(picker_data.options)
      picker_data.options.entry_maker = function(line)
        local base = base_entry_maker(line)
        local displayer = entry_display.create {
          separator = " ",
          items = { { width = icon_width }, { width = nil }, { remaining = true } },
        }
        base.display = function(entry)
          local tail, path = get_path_and_tail(entry.value)
          local icon, icon_hl = utils.get_devicons(tail)
          return displayer { { icon, icon_hl }, { tail }, { path, "@comment" } }
        end
        return base
      end
      require("telescope.builtin")[picker_data.picker](picker_data.options)
    end

    local grep = function(search, default_text, filetype, extra_opts)
      local grep_opts = {
        layout_strategy = "vertical",
        layout_config = {
          vertical = {
            prompt_position = "top",
            width = 0.45,
            height = 0.8,
            preview_width = SIZES.PREVIEW_WIDTH,
            mirror = true,
            preview_cutoff = 0,
            preview_height = 0.5,
          },
        },
      }
      local options = vim.tbl_deep_extend("force", grep_opts, extra_opts or {})
      -- if default_text then
      --   if not filetype then
      --     options.default_text = default_text
      --     options.initial_mode = "insert"
      --   else
      --     local escaped = default_text:gsub(".", function(c)
      --       return {
      --         ["\\"] = "\\\\", ["^"] = "\\^", ["$"] = "\\$",
      --         ["."] = "\\.", ["["] = "\\[", ["]"] = "\\]",
      --         ["("] = "\\(", [")"] = "\\)", ["{"] = "\\{", ["}"] = "\\}",
      --         ["*"] = "\\*", ["+"] = "\\+", ["-"] = "\\-", ["?"] = "\\?",
      --         ["|"] = "\\|", ["#"] = "\\#", ["&"] = "\\&", ["%"] = "\\%"
      --       }[c] or c
      --     end)
      --     options.default_text = (filetype ~= "" and "`" .. filetype .. " " or "") .. escaped:gsub("%s*\r?\n%s*", " ")
      --     options.initial_mode = "normal"
      --   end
      -- end
      local base_entry_maker = make_entry.gen_from_vimgrep(options)
      options.entry_maker = function(line)
        local base = base_entry_maker(line)
        local displayer = entry_display.create {
          separator = " ",
          items = { { width = icon_width }, { width = nil }, { remaining = true } },
        }
        base.display = function(entry)
          local tail = utils.path_tail(entry.filename)
          local icon, icon_hl = utils.get_devicons(tail)
          local coords = entry.lnum and (":" .. entry.lnum) or ""
          local text = (options.file_encoding and vim.iconv(entry.text, options.file_encoding, "utf8") or entry.text)
          return displayer { { icon, icon_hl }, { tail .. coords }, { "  " .. text, "@comment" } }
        end
        return base
      end
      require("telescope.builtin")[search](options)
    end

    local buffers = function(previewer, extra_opts)
      local opts = {
        bufnr_width = 0,
        layout_strategy = "horizontal",
        previewer = previewer,
        layout_config = {
          horizontal = {
            width = SIZES.WIDTH,
            height = SIZES.HEIGHT,
            preview_width = SIZES.PREVIEW_WIDTH,
          },
          mirror = false,
        },
      }
      opts = vim.tbl_deep_extend("force", opts, extra_opts or {})
      local base_entry_maker = make_entry.gen_from_buffer(opts)
      opts.entry_maker = function(line)
        local base = base_entry_maker(line)
        local displayer = entry_display.create {
          separator = " ",
          items = { { width = icon_width }, { width = nil }, { remaining = true } },
        }
        base.display = function(entry)
          local tail, path = get_path_and_tail(entry.filename)
          local icon, icon_hl = utils.get_devicons(tail)
          return displayer { { icon, icon_hl }, { tail }, { path, "@comment" } }
        end
        return base
      end
      require("telescope.builtin").buffers(opts)
    end

    -- Keymaps
    map("n", "<leader>fa",
      function() files("find", { hidden = true, follow = true, no_ignore = true, prompt_title = "All Files" }) end,
      { desc = "Find all files" })
    map("n", "<leader>ff", function() files("find", { prompt_title = "Files" }) end, { desc = "Find files" })
    map("n", "<leader>fr", function() files("old", { prompt_title = "Recent Files" }) end, { desc = "Recent files" })
    map("n", "<leader>fw", function() grep("live_grep", nil, nil, { prompt_title = "Live Grep" }) end,
      { desc = "Live grep" })
    map("n", "<leader>fb", function() buffers(true) end, { desc = "Buffers" })

    return vim.tbl_deep_extend("force", opts, {
      defaults = {
        prompt_prefix = "   ",
        selection_caret = " ",
        entry_prefix = " ",
        layout_config = {
          horizontal = { preview_width = 0.5 },
        },
        file_ignore_patterns = {
          "%.git/",
          "%.git",
          "node_modules",
          "node_modules/",
        },
        mappings = {
          i = {
            ["<C-j>"] = require("telescope.actions").move_selection_next,
            ["<C-k>"] = require("telescope.actions").move_selection_previous,
            ["<C-h>"] = require("telescope.actions.layout").toggle_preview,
            ["<F1>"] = require("telescope.actions.layout").toggle_preview,
          },
          n = {
            ["<C-h>"] = require("telescope.actions.layout").toggle_preview,
            ["<F1>"] = require("telescope.actions.layout").toggle_preview,
          },
        },
      },
    })
  end,
  config = function(_, opts)
    require("telescope").setup(opts)
    pcall(require("telescope").load_extension, "fzf")
  end,
}
