require "nvchad.autocmds"
vim.cmd [[autocmd BufNewFile,BufRead .env* set filetype=sh]]
vim.api.nvim_set_hl(0, "BufferLineOffset", { fg = "#cdd6f4", bg = "#191828", bold = true })

-- Enable auto-format globally
vim.g.autoformat_enabled = true

-- Format on save for supported file types
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.lua", "*.js", "*.ts", "*.jsx", "*.tsx", "*.css", "*.html", "*.json", "*.vue", "*.svelte", "*.go", "*.nix", "*.md" },
  callback = function()
    if vim.g.autoformat_enabled then
      vim.lsp.buf.format()
    end
  end,
})
