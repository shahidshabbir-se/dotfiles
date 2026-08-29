require "nvchad.options"

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.splitright = true
opt.splitbelow = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.cursorline = true
opt.mouse = ""
opt.scrolloff = 8
opt.clipboard = "unnamedplus"
opt.fillchars:append({ eob = " " })
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"
opt.undolevels = 10000
opt.timeoutlen = 300
opt.laststatus = 3
opt.wildmenu = true
opt.wildmode = "longest:full,full"
opt.wildoptions = "pum"

