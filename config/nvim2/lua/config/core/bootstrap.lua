vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

for _, plugin in ipairs({
	"gzip",
	"zip",
	"zipPlugin",
	"tar",
	"tarPlugin",
	"getscript",
	"getscriptPlugin",
	"vimball",
	"vimballPlugin",
	"2html_plugin",
	"logipat",
	"rrhelper",
	"netrw",
	"netrwPlugin",
}) do
	vim.g["loaded_" .. plugin] = 1
end

vim.api.nvim_create_autocmd("VimEnter", {
	pattern = "*",
	command = "set cmdheight=1",
	desc = "Force cmdheight to 1 to prevent override by plugins",
})

dofile(vim.fn.stdpath("config") .. "/lazy.lua")
require("keymaps")
require("config.diagnostics").setup()

vim.cmd([[colorscheme tokyonight]])
