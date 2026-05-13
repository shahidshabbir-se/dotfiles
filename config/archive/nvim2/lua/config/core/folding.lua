vim.opt.foldmethod = "indent"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext =
[[substitute(getline(v:foldstart), '\t', repeat(' ', &tabstop), 'g') . ' ... ' . (v:foldend - v:foldstart + 1) . ' lines']]
vim.opt.foldcolumn = "0"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 99
vim.opt.foldenable = true
