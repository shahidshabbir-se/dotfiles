require("nvchad.mappings")

local map = vim.keymap.set

-- Command Mode
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Menu Mappings
vim.keymap.set("n", "<C-t>", function()
	require("menu").open("default")
end, {})

vim.keymap.set({ "n", "v" }, "<RightMouse>", function()
	require("menu.utils").delete_old_menus()
	vim.cmd.exec('"normal! \\<RightMouse>"')

	local buf = vim.api.nvim_win_get_buf(vim.fn.getmousepos().winid)
	local options = vim.bo[buf].ft == "NvimTree" and "nvimtree" or "default"

	require("menu").open(options, { mouse = true })
end, {})

-- Select All
map("n", "<C-a>", "ggVG$", { desc = "Select all in NORMAL mode" })
map("v", "<C-a>", "<Esc>ggVG$", { desc = "Select all in VISUAL mode" })
map("i", "<C-a>", "<Esc>ggVG$", { desc = "Select all in INSERT mode" })

-- NvimTree
-- map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })

-- Sessions
map("n", "<leader>ss", "<cmd>SessionSearch<CR>", { noremap = true, silent = true, desc = "Search session" })
map("n", "<leader>sr", ":SessionRestore<CR>", { noremap = true, silent = true, desc = "Restore session" })

-- Remove Comments
map(
	"n",
	"<leader>kdc",
	[[:%s#// .*\|/\*.*\*/\|#.*\|--.*##g<CR>]],
	{ desc = "Remove all comment content", noremap = true, silent = true }
)

-- Buffer Management
map("n", "<leader>bc", function()
	local current_buf = vim.api.nvim_get_current_buf()
	local buffers = vim.api.nvim_list_bufs()

	for _, buf in ipairs(buffers) do
		if buf ~= current_buf and vim.api.nvim_buf_get_option(buf, "filetype") ~= "NvimTree" then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end

	local last_buf = vim.fn.bufnr("#")
	if last_buf ~= -1 and last_buf ~= current_buf then
		vim.cmd("buffer " .. last_buf)
	end
end, { desc = "Close all buffers except the current one and NvimTree" })

map("n", "<leader>ba", ":bufdo bd<CR>", { desc = "Close all buffers" })

map("n", "<leader>dob", ":!docker build .<CR>", { noremap = true, silent = true }) -- Build image
map("n", "<leader>dor", ":!docker run -it --rm <container_name><CR>", { noremap = true, silent = true }) -- Run container
map("n", "<leader>dos", ":!docker ps<CR>", { noremap = true, silent = true }) -- Show running containers

-- dap-python: Test method keymap
map("n", "<leader>dpr", function()
	require("dap-python").test_method()
end, { desc = "Run Python Test Method in DAP" })

map("n", "<leader>lc", function()
	local pos = vim.api.nvim_win_get_cursor(0)
	local bufnr = vim.api.nvim_get_current_buf()
	local diagnostics = vim.diagnostic.get(bufnr, { lnum = pos[1] - 1 })

	if diagnostics and #diagnostics > 0 then
		local msg = diagnostics[1].message
		vim.fn.setreg("+", msg)
		vim.notify(" Copied: " .. msg, vim.log.levels.INFO, { title = "LSP Diagnostic" })
	else
		vim.notify("No diagnostic under cursor", vim.log.levels.WARN, { title = "LSP Diagnostic" })
	end
end, { desc = "Copy LSP diagnostic under cursor" })

map("n", "<leader>hs", ":split<CR>", { desc = "Horizontal split" })
map("n", "<leader>vs", ":vsplit<CR>", { desc = "Vertical split" })

map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { noremap = true, silent = true })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { noremap = true, silent = true })

vim.keymap.set("n", "K", function()
	vim.lsp.buf.hover({
		border = "single",
		title = " Docs ",
	})
end)

-- Smart text objects for quotes
local function smart_quote(inner)
	return function()
		-- Grab character under cursor
		local c = vim.fn.getline("."):sub(vim.fn.col("."), vim.fn.col("."))
		-- Candidates: double, single, backtick
		local quotes = { '"', "'", "`" }

		-- If cursor is on a quote, use that
		for _, q in ipairs(quotes) do
			if c == q then
				return (inner and "i" or "a") .. q
			end
		end

		-- Otherwise, look backwards for nearest quote on this line
		local line = vim.fn.getline(".")
		local col = vim.fn.col(".")
		local left = line:sub(1, col)
		local found = left:match("[\"'`][^\"'`]*$")
		if found then
			local q = found:sub(1, 1)
			return (inner and "i" or "a") .. q
		end

		-- Fallback: double quotes
		return (inner and 'i"' or 'a"')
	end
end

map({ "o", "x" }, "iq", smart_quote(true), { expr = true })
map({ "o", "x" }, "aq", smart_quote(false), { expr = true })
