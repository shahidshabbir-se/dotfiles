vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "InsertLeave" }, {
	pattern = "*",
	callback = function()
		if vim.bo.modified and vim.bo.buftype == "" then
			if vim.lsp.buf.formatting_sync then
				vim.lsp.buf.formatting_sync()
			elseif vim.lsp.buf.format then
				vim.lsp.buf.format()
			end

			vim.cmd("write")
		end
	end,
	desc = "Auto-format and save on focus change or buffer leave",
})

vim.api.nvim_create_autocmd("VimLeave", {
	pattern = "*",
	callback = function()
		require("session_manager").save_current_session()
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	pattern = "*",
	callback = function()
		if vim.fn.argc() == 0 then -- If no files are passed, load the last session
			require("session_manager").load_last_session()
		end
	end,
})
