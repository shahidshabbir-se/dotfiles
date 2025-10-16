return {
  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = "tpope/vim-dadbod",
    ft = { "sql", "mysql", "plsql" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          local cmp = require "cmp"
          if cmp then
            local sources = vim.tbl_map(function(source)
              return { name = source.name }
            end, cmp.get_config().sources)

            table.insert(sources, { name = "vim-dadbod-completion" })
            cmp.setup.buffer { sources = sources }
          end
        end,
      })
    end,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    dependencies = "tpope/vim-dadbod",
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<CR>", desc = "Toggle DBUI" },
      { "<leader>da", "<cmd>DBUIAddConnection<CR>", desc = "Add a DB connection" },
      { "<leader>df", "<cmd>DBUIFindBuffer<CR>", desc = "Find DB buffer" },
      { "<leader>dq", "<cmd>DBUIToggle<CR>", desc = "Quick toggle DBUI" },
    },
    init = function()
      local data_path = vim.fn.stdpath "data"

      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
      vim.g.db_ui_show_database_icon = true
      vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
      vim.g.db_ui_use_nerd_fonts = true
      vim.g.db_ui_use_nvim_notify = true
      vim.g.db_ui_execute_on_save = false -- Prevent auto-running queries on save
    end,
  },
}
