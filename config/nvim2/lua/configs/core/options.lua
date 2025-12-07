require "nvchad.options"
vim.opt.number = true
vim.opt.backupcopy = "yes"
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.fillchars:append({ eob = " " })
vim.opt.smartcase = true
vim.opt.ignorecase = true
-- vim.opt.mouse = ""
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"
vim.opt.autoread = true
