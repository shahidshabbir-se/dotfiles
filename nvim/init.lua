-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.g.loaded_gzip = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.diagnostic.config({
  update_in_insert = false,
  virtual_text = { spacing = 2 },
})
vim.opt.updatetime = 250
vim.opt.synmaxcol = 200
vim.opt.pumblend = 0
