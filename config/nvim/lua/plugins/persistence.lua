return {
  "folke/persistence.nvim",

  lazy = false,

  opts = {
    options = {
      "buffers",
      "curdir",
      "tabpages",
      "winsize",
    },
  },

  init = function()
    local group = vim.api.nvim_create_augroup("PersistenceSession", {
      clear = true,
    })

    vim.api.nvim_create_autocmd("VimEnter", {
      group = group,
      nested = true,

      callback = vim.schedule_wrap(function()
        -- Restore the most recent session when Neovim is started:
        -- - with no args (`nvim`)
        -- - with a directory arg (`nvim .`, `nvim ~/project`)
        -- Won't restore when opening a specific file (`nvim file.txt`).
        local argc = vim.fn.argc()
        local arg = vim.fn.argv(0)

        local should_restore = argc == 0 or (argc == 1 and type(arg) == "string" and vim.fn.isdirectory(arg) == 1)

        if should_restore then
          pcall(require("persistence").load)

          -- Wipe directory buffers left over from `nvim .`.
          pcall(function()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              local name = vim.api.nvim_buf_get_name(buf)

              if name ~= "" and vim.fn.isdirectory(name) == 1 then
                vim.api.nvim_buf_delete(buf, { force = true })
              end
            end
          end)
        end
      end),
    })
  end,
}
