require("nvchad.options")

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
--
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local utils = require("shahid.utils")
local buf_map = utils.buf_map
autocmd("Filetype", {
	desc = "Prevent <Tab>/<S-Tab> from switching specific buffers.",
	pattern = {
		"lazy",
		"mason",
		"NvimTree",
		"qf",
	},
	group = augroup("PreventBufferSwap", { clear = true }),
	callback = function(event)
		local lhs_list = { "<Tab>", "<S-Tab>" }
		buf_map(event.buf, "n", lhs_list, "<nop>")
	end,
})

autocmd("VimResized", {
	desc = "Auto resize panes when resizing nvim window.",
	pattern = "*",
	group = augroup("VimAutoResize", { clear = true }),
	command = [[ tabdo wincmd = ]],
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	underline = true,
	virtual_text = {
		spacing = 5,
		-- severity_limit = "Warning",
	},
	update_in_insert = true,
})

autocmd("BufRead", {
	pattern = "query/*.sql",
	callback = function()
		-- Find and detach sqlls client
		local clients = vim.lsp.get_active_clients({ name = "sqlls" })
		for _, client in ipairs(clients) do
			vim.lsp.buf_detach_client(0, client.id)
		end
	end,
})

-- local function open_nvim_tree()
--   -- Check if Neovim was opened with exactly one argument and that it's a directory
--   local args = vim.fn.argv()
--   if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
--     require("nvim-tree.api").tree.open()
--   end
-- end

-- vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
