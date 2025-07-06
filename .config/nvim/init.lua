vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

dofile(vim.fn.stdpath("config") .. "/lazy.lua")
require("keymaps")
require("config.diagnostics").setup()

vim.cmd("colorscheme tokyonight")

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Highlight current line number brightly
vim.api.nvim_set_hl(0, "LineNr", { fg = "#aaaaaa" })

vim.opt.clipboard = "unnamedplus"

vim.opt.fillchars:append({ eob = " " })

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"

vim.api.nvim_set_hl(0, "Comment", { italic = true })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#7AA2F7", fg = "#1e1e2e", bold = true })
vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#94e2d5", bold = true })    -- teal
vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", { fg = "#a6e3a1", bold = true }) -- green
vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#7aa2f7" })                -- blue
vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = "#7aa2f7" })                  -- blue
vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = "#c0caf5" })                -- light fg
vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = "#ff9e64" })                -- orange
vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = "#e0af68" })                   -- yellow
vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = "#bb9af7" })               -- purple
vim.api.nvim_set_hl(0, "CmpItemKindProperty", { fg = "#9ece6a" })                -- green
vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = "#9ece6a" })                   -- green
vim.api.nvim_set_hl(0, "CmpItemKindEnum", { fg = "#f7768e" })                    -- red
vim.api.nvim_set_hl(0, "CmpItemKindEnumMember", { fg = "#f7768e" })              -- red
vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = "#bb9af7" })                 -- purple
vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = "#565f89" })                 -- gray
vim.api.nvim_set_hl(0, "CmpItemKindText", { fg = "#a9b1d6" })                    -- soft white
vim.api.nvim_set_hl(0, "CmpItemKindModule", { fg = "#9ece6a" })                  -- green
vim.api.nvim_set_hl(0, "CmpItemKindStruct", { fg = "#ff9e64" })                  -- orange
vim.api.nvim_set_hl(0, "CmpItemKindConstructor", { fg = "#7aa2f7" })             -- blue
vim.api.nvim_set_hl(0, "CmpItemKindTypeParameter", { fg = "#7dcfff" })           -- cyan
vim.api.nvim_set_hl(0, "CmpItemKindOperator", { fg = "#f7768e" })                -- red
vim.api.nvim_set_hl(0, "CmpItemKindEvent", { fg = "#e0af68" })                   -- yellow

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext =
[[substitute(getline(v:foldstart), '\t', repeat(' ', &tabstop), 'g') . ' ... ' . (v:foldend - v:foldstart + 1) . ' lines']]
vim.opt.foldcolumn = "0"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 4
vim.opt.foldenable = true
