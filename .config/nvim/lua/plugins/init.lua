return {
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		opts = require("configs.conform"),
	},

	-- # hey what are you doing
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("configs.lspconfig")
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		lazy = true,
		config = function()
			require("nvim-treesitter.configs").setup({
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["a="] = { query = "@assignment.outer", desc = "Select outer assignment" },
							["i="] = { query = "@assignment.inner", desc = "Select inner assignment" },
							["l="] = { query = "@assignment.lhs", desc = "Select left-hand assignment" },
							["r="] = { query = "@assignment.rhs", desc = "Select right-hand assignment" },

							["a:"] = { query = "@property.outer", desc = "Select outer property" },
							["i:"] = { query = "@property.inner", desc = "Select inner property" },
							["l:"] = { query = "@property.lhs", desc = "Select left property" },
							["r:"] = { query = "@property.rhs", desc = "Select right property" },

							["aa"] = { query = "@parameter.outer", desc = "Select outer parameter" },
							["ia"] = { query = "@parameter.inner", desc = "Select inner parameter" },

							["ai"] = { query = "@conditional.outer", desc = "Select outer conditional" },
							["ii"] = { query = "@conditional.inner", desc = "Select inner conditional" },

							["al"] = { query = "@loop.outer", desc = "Select outer loop" },
							["il"] = { query = "@loop.inner", desc = "Select inner loop" },

							["af"] = { query = "@call.outer", desc = "Select outer function call" },
							["if"] = { query = "@call.inner", desc = "Select inner function call" },

							["am"] = { query = "@function.outer", desc = "Select outer method" },
							["im"] = { query = "@function.inner", desc = "Select inner method" },

							["ac"] = { query = "@class.outer", desc = "Select outer class" },
							["ic"] = { query = "@class.inner", desc = "Select inner class" },

							["a/"] = { query = "@comment.outer", desc = "Select outer comment" },
							["i/"] = { query = "@comment.inner", desc = "Select inner comment" },
						},
					},
					move = {
						enable = true,
						goto_next_start = {
							["]f"] = "@function.outer",
							["]c"] = "@class.outer",
							["]a"] = "@parameter.inner",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]C"] = "@class.outer",
							["]A"] = "@parameter.inner",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[c"] = "@class.outer",
							["[a"] = "@parameter.inner",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[C"] = "@class.outer",
							["[A"] = "@parameter.inner",
						},
					},
					swap = {
						enable = true,
						swap_next = {
							["]s"] = "@parameter.inner", -- Swap parameter with next
							["]p"] = "@property.outer", -- Swap property with next
							["]m"] = "@function.outer", -- Swap function with next
						},
						swap_previous = {
							["[s"] = "@parameter.inner", -- Swap parameter with previous
							["[p"] = "@property.outer", -- Swap property with previous
							["[m"] = "@function.outer", -- Swap function with previous
						},
					},
				},
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			local treesitter = require("nvim-treesitter.configs")

			treesitter.setup({
				highlight = { enable = true },
				indent = { enable = true },
				ensure_installed = {
					"json",
					"javascript",
					"typescript",
					"tsx",
					"yaml",
					"html",
					"css",
					"prisma",
					"markdown",
					"markdown_inline",
					"svelte",
					"graphql",
					"bash",
					"lua",
					"vim",
					"dockerfile",
					"gitignore",
					"query",
					"go",
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						node_decremental = "<bs>",
					},
				},
			})
		end,
	},

	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		config = function()
			require("configs.mason")
		end,
	},

	{
		"folke/which-key.nvim",
		config = function()
			local which_key = require("which-key")
			which_key.setup({
				preset = "helix",
			})
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPre", "BufNewFile" },
		main = "ibl",
		opts = {
			indent = { char = "┊", tab_char = "┊" },
		},
	},

	{
		"echasnovski/mini.move",
		event = "VeryLazy",
		config = function()
			require("configs.mini-move")
		end,
	},

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				config = function(_, opts)
					require("luasnip").config.set_config(opts)

					local luasnip = require("luasnip")

					luasnip.filetype_extend("javascriptreact", { "html" })
					luasnip.filetype_extend("typescriptreact", { "html" })
					luasnip.filetype_extend("svelte", { "html" })

					require("nvchad.configs.luasnip")
				end,
			},

			{
				"hrsh7th/cmp-cmdline",
				event = "CmdlineEnter",
				config = function()
					local cmp = require("cmp")

					cmp.setup.cmdline("/", {
						mapping = cmp.mapping.preset.cmdline(),
						sources = { { name = "buffer" } },
					})

					cmp.setup.cmdline(":", {
						mapping = cmp.mapping.preset.cmdline(),
						sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
						matching = { disallow_symbol_nonprefix_matching = false },
					})
				end,
			},
		},

		opts = function(_, opts)
			table.insert(opts.sources, 1, {
				name = "copilot",
				group_index = 1,
				priority = 100,
			})
			-- table.insert(opts.sources, { name = "crates" })
		end,
	},

	{
		"echasnovski/mini.animate",
		event = "VeryLazy",
		cond = vim.g.neovide == nil,
		opts = function(_, opts)
			-- don't use animate when scrolling with the mouse
			local mouse_scrolled = false
			for _, scroll in ipairs({ "Up", "Down" }) do
				local key = "<ScrollWheel" .. scroll .. ">"
				vim.keymap.set({ "", "i" }, key, function()
					mouse_scrolled = true
					return key
				end, { expr = true })
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "grug-far",
				callback = function()
					vim.b.minianimate_disable = true
				end,
			})

			local animate = require("mini.animate")
			return vim.tbl_deep_extend("force", opts, {
				resize = {
					timing = animate.gen_timing.linear({ duration = 50, unit = "total" }),
				},
				scroll = {
					timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
					subscroll = animate.gen_subscroll.equal({
						predicate = function(total_scroll)
							if mouse_scrolled then
								mouse_scrolled = false
								return false
							end
							return total_scroll > 1
						end,
					}),
				},
			})
		end,
	},

	{
		"sphamba/smear-cursor.nvim",
		event = "VeryLazy",
		cond = vim.g.neovide == nil,
		opts = {
			hide_target_hack = true,
			cursor_color = "none",
		},
		specs = {
			-- disable mini.animate cursor
			{
				"echasnovski/mini.animate",
				optional = true,
				opts = {
					cursor = { enable = false },
				},
			},
		},
	},

	{
		"echasnovski/mini.indentscope",
		version = false, -- wait till new 0.7.0 release to put it back on semver
		event = "VimEnter",
		opts = {
			-- symbol = "▏",
			symbol = "│",
			options = { try_as_border = true },
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"Trouble",
					"alpha",
					"dashboard",
					"fzf",
					"help",
					"lazy",
					"mason",
					"NvimTree",
					"neo-tree",
					"notify",
					"toggleterm",
					"trouble",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},

	{
		"razak17/tailwind-fold.nvim",
		ft = { "html", "svelte", "astro", "vue", "typescriptreact" },
		opts = {
			min_chars = 40,
		},
	},

	{
		"okuuva/auto-save.nvim",
		event = { "InsertLeave", "TextChanged" },
		opts = {
			callbacks = {
				before_saving = function()
					-- save global autoformat status
					vim.g.OLD_AUTOFORMAT = vim.g.autoformat_enabled
					vim.g.autoformat_enabled = false
					vim.g.OLD_AUTOFORMAT_BUFFERS = {}
					-- disable all manually enabled buffers
					for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
						if vim.b[bufnr].autoformat_enabled then
							table.insert(vim.g.OLD_BUFFER_AUTOFORMATS, bufnr)
							vim.b[bufnr].autoformat_enabled = false
						end
					end
				end,
				after_saving = function()
					-- restore global autoformat status
					vim.g.autoformat_enabled = vim.g.OLD_AUTOFORMAT
					-- reenable all manually enabled buffers
					for _, bufnr in ipairs(vim.g.OLD_AUTOFORMAT_BUFFERS or {}) do
						vim.b[bufnr].autoformat_enabled = true
					end
				end,
			},
		},
	},

	{
		"Wansmer/treesj",
		keys = { { "<leader>m", "<CMD>TSJToggle<CR>", desc = "Toggle Treesitter Join" } },
		cmd = { "TSJToggle" },
		opts = { use_default_keymaps = false },
		init = function()
			local map = vim.keymap.set

			map("n", "<leader>tt", "<CMD>TSJToggle<CR>", { desc = "Toggle Treesitter Join/Split" })
		end,
	},

	{
		"folke/trouble.nvim",
		cmd = { "Trouble", "TroubleToggle", "TodoTrouble" },
		dependencies = {
			{
				"folke/todo-comments.nvim",
				opts = {},
			},
		},
		opts = {},
		init = function()
			local map = vim.keymap.set

			map("n", "<leader>t", "<CMD>Trouble diagnostics toggle<CR>", { desc = "Toggle diagnostics" })
			map(
				"n",
				"<leader>td",
				"<CMD>TodoTrouble keywords=TODO,FIX,FIXME,BUG,TEST,NOTE<CR>",
				{ desc = "Todo/Fix/Fixme" }
			)
		end,
	},

	{
		"chikko80/error-lens.nvim",
		event = "LspAttach",
		opts = {},
	},

	{
		"RRethy/vim-illuminate",
		event = { "CursorHold", "CursorHoldI" },
		dependencies = "nvim-treesitter",
		config = function()
			require("illuminate").configure({
				under_cursor = true,
				max_file_lines = nil,
				delay = 100,
				providers = {
					"lsp",
					"treesitter",
					"regex",
				},
				filetypes_denylist = {
					"NvimTree",
					"Trouble",
					"Outline",
					"TelescopePrompt",
					"Empty",
					"dirvish",
					"fugitive",
					"alpha",
					"packer",
					"neogitstatus",
					"spectre_panel",
					"toggleterm",
					"DressingSelect",
					"aerial",
				},
			})
		end,
	},

	{
		"folke/todo-comments.nvim",
		event = "BufReadPre",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},

	{
		"mfussenegger/nvim-dap",
		desc = "Debugging support. Requires language-specific adapters to be configured.",

		dependencies = {
			"rcarriga/nvim-dap-ui",
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},
		},

		keys = {
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Breakpoint Condition",
			},
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Run/Continue",
			},
			{
				"<leader>da",
				function()
					require("dap").continue({ before = get_args })
				end,
				desc = "Run with Args",
			},
			{
				"<leader>dC",
				function()
					require("dap").run_to_cursor()
				end,
				desc = "Run to Cursor",
			},
			{
				"<leader>dg",
				function()
					require("dap").goto_()
				end,
				desc = "Go to Line (No Execute)",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step Into",
			},
			{
				"<leader>dj",
				function()
					require("dap").down()
				end,
				desc = "Down",
			},
			{
				"<leader>dk",
				function()
					require("dap").up()
				end,
				desc = "Up",
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				desc = "Run Last",
			},
			{
				"<leader>do",
				function()
					require("dap").step_out()
				end,
				desc = "Step Out",
			},
			{
				"<leader>dO",
				function()
					require("dap").step_over()
				end,
				desc = "Step Over",
			},
			{
				"<leader>dP",
				function()
					require("dap").pause()
				end,
				desc = "Pause",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Toggle REPL",
			},
			{
				"<leader>ds",
				function()
					require("dap").session()
				end,
				desc = "Session",
			},
			{
				"<leader>dt",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate",
			},
			{
				"<leader>dw",
				function()
					require("dap.ui.widgets").hover()
				end,
				desc = "Widgets",
			},
		},

		config = function()
			vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

			-- Define DAP signs
			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn" })

			-- Setup DAP configuration via VSCode launch.json
			local vscode = require("dap.ext.vscode")
			local json = require("plenary.json")
			vscode.json_decode = function(str)
				return vim.json.decode(json.json_strip_comments(str))
			end
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		keys = {
			{
				"<leader>du",
				function()
					require("dapui").toggle({})
				end,
				desc = "Dap UI",
			},
			{
				"<leader>de",
				function()
					require("dapui").eval()
				end,
				desc = "Eval",
				mode = { "n", "v" },
			},
		},
		opts = {},
		config = function(_, opts)
			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup(opts)

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open({})
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close({})
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close({})
			end
		end,
	},

	-- Optional Node.js Debug Adapter configuration
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{
				"williamboman/mason.nvim",
			},
			{
				"leoluz/nvim-dap-go",
				config = function()
					require("dap-go").setup()
				end,
			},
		},
		config = function()
			local dap = require("dap")
			dap.adapters.lldb = {
				type = "server",
				port = 10000, -- this can be any port you like
				executable = {
					command = "/home/shahid/codelldb-wrapper.sh",
					args = { "--port", "10000" },
				},
			}

			-- PWA Node.js Adapter
			if not dap.adapters["pwa-node"] then
				dap.adapters["pwa-node"] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "node",
						args = {
							require("mason-registry").get_package("js-debug-adapter"):get_install_path()
								.. "/js-debug/src/dapDebugServer.js",
							"${port}",
						},
					},
				}
			end

			local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

			for _, language in ipairs(js_filetypes) do
				if not dap.configurations[language] then
					dap.configurations[language] = {
						{
							type = "pwa-node",
							request = "launch",
							name = "Launch file",
							program = "${file}",
							cwd = "${workspaceFolder}",
						},
						{
							type = "pwa-node",
							request = "attach",
							name = "Attach",
							processId = require("dap.utils").pick_process,
							cwd = "${workspaceFolder}",
						},
					}
				end
			end
		end,
	},
	{
		"nvim-neotest/nvim-nio",
		dependencies = {
			"mfussenegger/nvim-dap",
			"rcarriga/nvim-dap-ui",
		},
	},

	{
		"theHamsta/nvim-dap-virtual-text",
		lazy = false,
		config = function(_, opts)
			require("nvim-dap-virtual-text").setup()
		end,
	},

	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
		},
	},
	{
		"rmagatti/auto-session",
		lazy = false,

		opts = {
			-- Specify a directory to store all session files.
			root_dir = vim.fn.stdpath("data") .. "/sessions/", -- Store all sessions in this directory (e.g., ~/.local/share/nvim/sessions/)

			-- Auto-save and auto-restore settings
			auto_save = true, -- Enable auto-save of sessions on exit
			auto_restore = false, -- Enable auto-restore of sessions on startup
			auto_create = true, -- Enable automatic creation of a new session if no session exists
			auto_restore_last_session = true, -- Restore the last session automatically on startup, if no session for cwd exists

			-- Control the directories where sessions are not handled
			suppressed_dirs = { "~/", "~/Downloads", "/" }, -- Don't manage sessions in these directories

			-- Manual session control (you can choose to save, restore, or delete a session based on cwd or session name)
			session_lens = {
				load_on_setup = true, -- Enable session picker for sessions (requires Telescope)
				previewer = false, -- Disable session file preview
			},

			-- Logging and error handling options
			log_level = "error", -- Set the log level to "error" to reduce log noise

			-- Optionally, configure any other settings
			lazy_support = true, -- Automatically detect if Lazy.nvim is used and wait for it to finish loading
		},
	},

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
					accept = "<Tab>", -- Accept suggestion (VS Code-like)
					next = "<M-]>", -- Next suggestion
					prev = "<M-[>", -- Previous suggestion
					dismiss = "<C-]>", -- Dismiss suggestion
				},
			},
			panel = {
				enabled = false, -- Disable Copilot Panel (optional)
			},
			filetypes = {
				markdown = true,
				help = true,
				lua = true,
				go = true,
				javascript = true,
				typescript = true,
				python = true,
			},
		},
	},
}
