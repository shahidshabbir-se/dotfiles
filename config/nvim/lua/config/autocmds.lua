vim.cmd([[autocmd BufNewFile,BufRead .env* set filetype=sh]])

-- Enable auto-format globally
vim.g.autoformat_enabled = true

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = {
    "*.lua",
    "*.js",
    "*.ts",
    "*.jsx",
    "*.tsx",
    "*.css",
    "*.html",
    "*.json",
    "*.vue",
    "*.svelte",
    "*.go",
    "*.nix",
    "*.md",
    "Dockerfile*",
    "*.dockerfile",
    "*.yaml",
    "*.yml",
    "*.rs",
  },
  callback = function()
    if vim.g._autosave_lock then
      return
    end

    vim.g._autosave_lock = true

    local ft = vim.bo.filetype

    -- TypeScript / JS import organization (target ts_ls specifically to avoid Copilot errors)
    if ft == "typescript" or ft == "typescriptreact" or ft == "javascript" or ft == "javascriptreact" then
      local clients = vim.lsp.get_clients({ bufnr = 0, name = "ts_ls" })
      if clients[1] then
        clients[1]:request("workspace/executeCommand", {
          command = "_typescript.organizeImports",
          arguments = { vim.api.nvim_buf_get_name(0) },
        }, nil, 0)
      end
    end

    -- Svelte import organization
    if ft == "svelte" then
      vim.lsp.buf.code_action({
        context = {
          only = { "source.organizeImports" },
          diagnostics = {},
        },
        apply = true,
      })
    end

    if vim.g.autoformat_enabled then
      vim.lsp.buf.format({ async = false })
    end

    vim.g._autosave_lock = false
  end,
})

-- -- Close the startup directory buffer (e.g. "[nvim]") when launching in a folder
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function(data)
--     local directory = vim.fn.isdirectory(data.file) == 1
--     if directory then
--       vim.cmd("bd") -- close the [nvim] buffer
--     end
--   end,
-- })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  command = "checktime",
})

