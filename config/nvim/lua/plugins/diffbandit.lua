local function get_tokyonight_theme()
  local ok, colors = pcall(require, "tokyonight.colors")
  local c = ok and colors.setup({ transform = true }) or {
    border = "#1b1d2b",
    bg_dark = "#1e2030",
    bg_statusline = "#1e2030",
    fg = "#c8d3f5",
    fg_dark = "#828bb8",
    fg_gutter = "#3b4261",
    blue = "#82aaff",
    cyan = "#86e1fc",
    green = "#c3e88d",
    red = "#ff757f",
    magenta = "#c099ff",
    comment = "#636da6",
  }

  return {
    -- Base transparent backgrounds
    DiffBanditContext = { bg = "NONE" },
    DiffBanditConnectorContext = { bg = "NONE" },
    DiffBanditOverviewContext = { bg = "NONE" },
    DiffBanditSignColumn = { bg = "NONE" },
    DiffBanditGap = { link = "Comment", bg = "NONE" },
    DiffBanditPlaceholder = { link = "Comment", bg = "NONE" },
    DiffBanditEmptyNotice = { link = "Comment", italic = true, bg = "NONE" },

    -- Line numbers (Tokyonight gutter fg, transparent bg)
    DiffBanditLineNumberLeft = { fg = c.fg_gutter, bg = "NONE" },
    DiffBanditLineNumberRight = { fg = c.fg_gutter, bg = "NONE" },

    -- Subtle window borders
    DiffBanditSplit = { fg = c.border, bg = "NONE" },
    DiffBanditHiddenSplit = { fg = c.bg_dark, bg = "NONE" },

    -- Commit panel (transparent background with Tokyonight fg colors)
    DiffBanditStatus = { fg = c.fg, bg = "NONE" },
    DiffBanditAccentText = { fg = c.blue, bold = true },
    DiffBanditMutedText = { fg = c.comment },

    -- Header bar (matches Tokyonight statusline styling)
    DiffBanditStatusLine = { fg = c.fg_dark, bg = c.bg_statusline },
    DiffBanditStatusAccent = { fg = c.magenta, bold = true, bg = c.bg_statusline },
    DiffBanditStatusMuted = { fg = c.cyan, bg = c.bg_statusline },

    -- Additions (Tokyonight green)
    DiffBanditAdd = { bg = "#203a34", fg = "NONE" },
    DiffBanditAddLeft = { bg = "#203a34", fg = "NONE", underline = true, sp = c.green },
    DiffBanditConnectorAdd = { bg = "#203a34", fg = c.green },
    DiffBanditConnectorAddLine = { fg = c.green, bold = true },
    DiffBanditConnectorExpansionAdd = { fg = c.green, bg = "NONE", bold = true },
    DiffBanditConnectorExpansionAddUnderline = { fg = c.green, bg = "NONE", underline = true, sp = c.green, bold = true },
    DiffBanditOverviewAdd = { bg = c.green, fg = c.green },
    DiffBanditLineNumberRightAdd = { fg = c.green, bg = "#203a34", bold = true },
    DiffBanditSignAdd = { fg = c.green, bg = "NONE" },

    -- Deletions (Tokyonight red)
    DiffBanditDelete = { bg = "#3f2229", fg = "NONE" },
    DiffBanditConnectorDelete = { bg = "#3f2229", fg = c.red },
    DiffBanditConnectorDeleteLine = { fg = c.red, bold = true },
    DiffBanditConnectorExpansionDelete = { fg = c.red, bg = "NONE", bold = true },
    DiffBanditOverviewDelete = { bg = c.red, fg = c.red },
    DiffBanditLineNumberLeftDelete = { fg = c.red, bg = "#3f2229", bold = true },

    -- Changes (Tokyonight blue & cyan)
    DiffBanditChangeLeft = { bg = "#22314a", fg = "NONE" },
    DiffBanditChangeRight = { bg = "#22314a", fg = "NONE" },
    DiffBanditChangeEmphasis = { bg = "#2f4268", fg = "NONE", bold = true },
    DiffBanditConnectorChange = { bg = "#22314a", fg = c.blue },
    DiffBanditConnectorChangeLine = { fg = c.blue, bold = true },
    DiffBanditConnectorExpansionChange = { fg = c.blue, bg = "NONE", bold = true },
    DiffBanditOverviewChange = { bg = c.blue, fg = c.blue },
    DiffBanditLineNumberLeftChange = { fg = c.blue, bg = "#22314a", bold = true },
    DiffBanditLineNumberRightChange = { fg = c.blue, bg = "#22314a", bold = true },
    DiffBanditSignChange = { fg = c.blue, bg = "NONE" },
  }
end

return {
  -- Disable lazygit & gitui plugins
  { "kdheepak/lazygit.nvim", enabled = false },
  { "gitui", enabled = false },
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = { enabled = false },
    },
  },

  -- DiffBandit
  {
    "CoreyKaylor/diffbandit.nvim",
    cmd = {
      "DiffBandit",
      "DiffBanditBuffers",
      "DiffBanditGit",
      "DiffBanditGitCurrent",
      "DiffBanditCommitPanel",
      "DiffBanditGitMenu",
      "DiffBanditGitLog",
      "DiffBanditGitCommit",
      "DiffBanditGitCompare",
      "DiffBanditGitCheckout",
      "DiffBanditMerge",
      "DiffBanditFolderDiff",
      "DiffBanditLaunch",
      "DiffBanditToggleStageHunk",
      "DiffBanditStageHunk",
      "DiffBanditUnstageHunk",
      "DiffBanditDiscardHunk",
      "DiffBanditApplyLeftHunk",
      "DiffBanditApplyRightHunk",
      "DiffBanditUndo",
      "LazyGit",
      "GitUi",
    },
    keys = {
      {
        "<leader>gg",
        function()
          local root = LazyVim and LazyVim.root and LazyVim.root.git() or nil
          require("diffbandit").git_panel({ root = root })
        end,
        desc = "DiffBandit (Root Dir)",
      },
      {
        "<leader>gG",
        function()
          local cwd = (vim.uv or vim.loop).cwd()
          require("diffbandit").git_panel({ root = cwd })
        end,
        desc = "DiffBandit (cwd)",
      },
      {
        "<leader>lg",
        function()
          local root = LazyVim and LazyVim.root and LazyVim.root.git() or nil
          require("diffbandit").git_panel({ root = root })
        end,
        desc = "DiffBandit (Root Dir)",
      },
    },
    init = function()
      -- Override LazyVim default lazygit keymaps when LazyVimKeymaps event triggers
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimKeymaps",
        once = true,
        callback = function()
          vim.keymap.set("n", "<leader>gg", function()
            local root = LazyVim and LazyVim.root and LazyVim.root.git() or nil
            require("diffbandit").git_panel({ root = root })
          end, { desc = "DiffBandit (Root Dir)" })

          vim.keymap.set("n", "<leader>gG", function()
            local cwd = (vim.uv or vim.loop).cwd()
            require("diffbandit").git_panel({ root = cwd })
          end, { desc = "DiffBandit (cwd)" })

          vim.keymap.set("n", "<leader>lg", function()
            local root = LazyVim and LazyVim.root and LazyVim.root.git() or nil
            require("diffbandit").git_panel({ root = root })
          end, { desc = "DiffBandit (Root Dir)" })
        end,
      })

      -- Aliases for muscle memory
      vim.api.nvim_create_user_command("LazyGit", function()
        local root = LazyVim and LazyVim.root and LazyVim.root.git() or nil
        require("diffbandit").git_panel({ root = root })
      end, { desc = "DiffBandit (LazyGit alias)" })

      vim.api.nvim_create_user_command("GitUi", function()
        local root = LazyVim and LazyVim.root and LazyVim.root.git() or nil
        require("diffbandit").git_panel({ root = root })
      end, { desc = "DiffBandit (GitUi alias)" })
    end,
    opts = function()
      return {
        ui = {
          theme = {
            highlights = get_tokyonight_theme(),
          },
        },
      }
    end,
    config = function(_, opts)
      require("diffbandit").setup(opts)
    end,
  },
}
