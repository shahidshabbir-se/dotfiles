return {
	"okuuva/auto-save.nvim",
	event = { "InsertLeave" },
	opts = {
		condition = function()
			return not vim.g._autosave_lock
		end,
	},
}
