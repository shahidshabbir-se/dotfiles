return {
  "rmagatti/auto-session",
  lazy = false,
  opts = {
    suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
    auto_restore = false, -- Disabled so plain `nvim` shows NvChad dashboard
    auto_save = true,
    auto_create = true,
    bypass_save_filetypes = { "alpha", "dashboard", "nvdash", "neo-tree", "NvimTree" },
    close_unsupported_winnrs = true,
    pre_save_cmds = {
      function()
        local ok, neotree = pcall(require, "neo-tree.command")
        if ok then
          neotree.execute({ action = "close" })
        end
      end,
    },
    post_restore_cmds = {
      function()
        vim.schedule(function()
          -- Reload active restored buffer to trigger full filetype, treesitter & LSP initialization
          vim.cmd("silent! e")
        end)
      end,
    },
  },
  config = function(_, opts)
    -- Optimal sessionoptions recommended by auto-session docs
    vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"

    local auto_session = require("auto-session")
    auto_session.setup(opts)

    -- Auto-restore session ONLY when launched with a directory argument like `nvim .`
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("AutoRestoreOnDir", { clear = true }),
      nested = true,
      callback = function()
        if vim.fn.argc() == 1 then
          local arg = vim.fn.argv(0)
          if vim.fn.isdirectory(arg) == 1 then
            auto_session.restore_session()
          end
        end
      end,
    })
  end,
  keys = {
    { "<leader>sr", "<cmd>AutoSession restore<cr>", desc = "Restore Session" },
    { "<leader>ss", "<cmd>AutoSession search<cr>", desc = "Search Sessions" },
    { "<leader>sa", "<cmd>AutoSession save<cr>", desc = "Save Session" },
  },
}
