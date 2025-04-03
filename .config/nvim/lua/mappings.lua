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
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })

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
