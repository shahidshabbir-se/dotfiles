return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		build = ":Copilot auth",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				hide_during_completion = false,
				keymap = {
					accept = "<C-f>", -- Accept suggestion (VS Code-like)
					next = "<M-]>", -- Next suggestion
					prev = "<M-[>", -- Previous suggestion
					dismiss = "<C-x>", -- Dismiss suggestion
				},
			},
			panel = {
				enabled = false, -- Disable Copilot Panel (optional)
			},
			filetypes = {
				markdown = true,
				help = true,
				lua = true,
				javascript = true,
				typescript = true,
				python = true,
				astro = true,
				tsx = true,
				jsx = true,
				yml = true,
				yaml = true,
				svelte = true,
			},
		},
	},

	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "main",
		cmd = "CopilotChat",
		opts = function()
			local user = vim.env.USER or "User"
			user = user:sub(1, 1):upper() .. user:sub(2)

			return {
				auto_insert_mode = true,
				question_header = "  " .. user .. " ",
				answer_header = "  Copilot ",
				window = {
					width = 0.4,
				},
			}
		end,
		keys = {
			{ "<C-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
			{ "<leader>a", "", desc = "+AI", mode = { "n", "v" } },
			{
				"<leader>aa",
				function()
					require("CopilotChat").toggle()
				end,
				desc = "Toggle (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<leader>ax",
				function()
					require("CopilotChat").reset()
				end,
				desc = "Clear (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<leader>aq",
				function()
					local input = vim.fn.input("Quick Chat: ")
					if input ~= "" then
						require("CopilotChat").ask(input)
					end
				end,
				desc = "Quick Chat (CopilotChat)",
				mode = { "n", "v" },
			},
		},
		config = function(_, opts)
			local chat = require("CopilotChat")

			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-chat",
				callback = function()
					vim.opt_local.relativenumber = false
					vim.opt_local.number = false
					vim.diagnostic.reset()
				end,
			})

			chat.setup(opts)
		end,
	},
}
