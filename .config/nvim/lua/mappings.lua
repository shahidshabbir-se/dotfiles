require("nvchad.mappings")

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })

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

map("n", "<C-a>", "ggVG$", { desc = "Select all in NORMAL mode" })
map("v", "<C-a>", "<Esc>ggVG$", { desc = "Select all in VISUAL mode" })
map("i", "<C-a>", "<Esc>ggVG$", { desc = "Select all in INSERT mode" })
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree focus window" })
map("n", "<leader>ss", "<cmd>SessionSearch<CR>", { noremap = true, silent = true })
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
