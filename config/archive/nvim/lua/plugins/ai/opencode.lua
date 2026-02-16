return {
	"sudo-tee/opencode.nvim",
	config = function()
		-- Define custom highlights for a polished look
		local set_hl = vim.api.nvim_set_hl
		set_hl(0, "OpencodeBorder", { link = "FloatBorder" })
		set_hl(0, "OpencodeBackground", { link = "NormalFloat" })
		set_hl(0, "OpencodeDiffAdd", { link = "DiffAdd" })
		set_hl(0, "OpencodeDiffDelete", { link = "DiffDelete" })
		set_hl(0, "OpencodeInputLegend", { link = "Comment" })

		require("opencode").setup({
			preferred_picker = "telescope",
			preferred_completion = "nvim-cmp",
			default_global_keymaps = true,
			default_mode = "build",
			default_system_prompt = nil,
			keymap_prefix = "<leader>o",
			opencode_executable = "opencode",
			keymap = {
				editor = {
					["<leader>og"] = { "toggle" },
					["<leader>oi"] = { "open_input" },
					["<leader>oI"] = { "open_input_new_session" },
					["<leader>oo"] = { "open_output" },
					["<leader>ot"] = { "toggle_focus" },
					["<leader>oT"] = { "timeline" },
					["<leader>oq"] = { "close" },
					["<leader>os"] = { "select_session" },
					["<leader>oR"] = { "rename_session" },
					["<leade>op"] = { "configure_provider" },
					["<leader>oV"] = { "configure_variant" },
					["<leader>oz"] = { "toggle_zoom" },
					["<leader>ov"] = { "paste_image" },
					["<leader>od"] = { "diff_open" },
					["<leader>o]"] = { "diff_next" },
					["<leader>o["] = { "diff_prev" },
					["<leader>oc"] = { "diff_close" },
					["<leader>ora"] = { "diff_revert_all_last_prompt" },
					["<leader>ort"] = { "diff_revert_this_last_prompt" },
					["<leader>orA"] = { "diff_revert_all" },
					["<leader>orT"] = { "diff_revert_this" },
					["<leader>orr"] = { "diff_restore_snapshot_file" },
					["<leader>orR"] = { "diff_restore_snapshot_all" },
					["<leader>ox"] = { "swap_position" },
					["<leader>ott"] = { "toggle_tool_output" },
					["<leader>otr"] = { "toggle_reasoning_output" },
					["<leader>o/"] = { "quick_chat", mode = { "n", "x" } },
				},
				input_window = {
					["<S-cr>"] = { "submit_input_prompt", mode = { "n", "i" } },
					["<esc>"] = { "close" },
					["<C-c>"] = { "cancel" },
					["~"] = { "mention_file", mode = "i" },
					["@"] = { "mention", mode = "i" },
					["/"] = { "slash_commands", mode = "i" },
					["#"] = { "context_items", mode = "i" },
					["<M-v>"] = { "paste_image", mode = "i" },
					["<C-i>"] = { "focus_input", mode = { "n", "i" } },
					["<tab>"] = { "toggle_pane", mode = { "n", "i" } },
					["<up>"] = { "prev_prompt_history", mode = { "n", "i" } },
					["<down>"] = { "next_prompt_history", mode = { "n", "i" } },
					["<M-m>"] = { "switch_mode" },
					["<M-r>"] = { "cycle_variant", mode = { "n", "i" } },
				},
				output_window = {
					["<esc>"] = { "close" },
					["<C-c>"] = { "cancel" },
					["]]"] = { "next_message" },
					["[["] = { "prev_message" },
					["<tab>"] = { "toggle_pane", mode = { "n", "i" } },
					["i"] = { "focus_input", "n" },
					["<M-r>"] = { "cycle_variant", mode = { "n" } },
					["<leader>oS"] = { "select_child_session" },
					["<leader>oD"] = { "debug_message" },
					["<leader>oO"] = { "debug_output" },
					["<leader>ods"] = { "debug_session" },
				},
				session_picker = {
					rename_session = { "<C-r>" },
					delete_session = { "<C-d>" },
					new_session = { "<C-s>" },
				},
				timeline_picker = {
					undo = { "<C-u>", mode = { "i", "n" } },
					fork = { "<C-f>", mode = { "i", "n" } },
				},
				history_picker = {
					delete_entry = { "<C-d>", mode = { "i", "n" } },
					clear_all = { "<C-X>", mode = { "i", "n" } },
				},
				model_picker = {
					toggle_favorite = { "<C-f>", mode = { "i", "n" } },
				},
				mcp_picker = {
					toggle_connection = { "<C-t>", mode = { "i", "n" } },
				},
			},
			ui = {
				position = "right",
				input_positionto = "top",
				window_width = 0.40,
				zoom_width = 0.8,
				input_height = 0.15,
				display_model = true,
				display_context_size = false,
				display_cost = false,
				window_highlight = "Normal:OpencodeBackground,FloatBorder:OpencodeBorder",
				icons = {
					preset = "nerdfonts",
					overrides = {
						header_user = "  ",
						header_assistant = "  ",
					},
				},
				output = {
					tools = {
						show_output = true,
						show_reasoning_output = true,
					},
					rendering = {
						markdown_debounce_ms = 250,
						on_data_rendered = nil,
					},
				},
				input = {
					text = {
						wrap = true,
					},
				},
				picker = {
					snacks_layout = nil, -- `layout` opts to pass to Snacks.picker.pick({ layout = ... })
				},
				completion = {
					file_sources = {
						enabled = true,
						preferred_cli_tool = "server", -- 'fd','fdfind','rg','git','server' if nil, it will use the best available tool, 'server' uses opencode cli to get file list (works cross platform) and supports folders
						ignore_patterns = {
							"^%.git/",
							"^%.svn/",
							"^%.hg/",
							"node_modules/",
							"%.pyc$",
							"%.o$",
							"%.obj$",
							"%.exe$",
							"%.dll$",
							"%.so$",
							"%.dylib$",
							"%.class$",
							"%.jar$",
							"%.war$",
							"%.ear$",
							"target/",
							"build/",
							"dist/",
							"out/",
							"deps/",
							"%.tmp$",
							"%.temp$",
							"%.log$",
							"%.cache$",
						},
						max_files = 10,
						max_display_length = 50, -- Maximum length for file path display in completion, truncates from left with "..."
					},
				},
			},
			context = {
				enabled = true, -- Enable automatic context capturing
				cursor_data = {
					enabled = false, -- Include cursor position and line content in the context
					context_lines = 5, -- Number of lines before and after cursor to include in context
				},
				diagnostics = {
					info = false, -- Include diagnostics info in the context (default to false
					warn = true, -- Include diagnostics warnings in the context
					error = true, -- Include diagnostics errors in the context
					only_closest = false, -- If true, only diagnostics for cursor/selection
				},
				current_file = {
					enabled = true, -- Include current file path and content in the context
					show_full_path = true,
				},
				files = {
					enabled = true,
					show_full_path = true,
				},
				selection = {
					enabled = true, -- Include selected text in the context
				},
				buffer = {
					enabled = false, -- Disable entire buffer context by default, only used in quick chat
				},
				git_diff = {
					enabled = false,
				},
			},
			debug = {
				enabled = false, -- Enable debug messages in the output window
				capture_streamed_events = false,
				show_ids = true,
				quick_chat = {
					keep_session = false, -- Keep quick_chat sessions for inspection, this can pollute your sessions list
					set_active_session = false,
				},
			},
			prompt_guard = nil, -- Optional function that returns boolean to control when prompts can be sent (see Prompt Guard section)

			-- User Hooks for custom behavior at certain events
			hooks = {
				on_file_edited = nil, -- Called after a file is edited by opencode.
				on_session_loaded = nil, -- Called after a session is loaded.
				on_done_thinking = nil, -- Called when opencode finishes thinking (all jobs complete).
				on_permission_requested = nil, -- Called when a permission request is issued.
			},
			quick_chat = {
				default_model = nil, -- works better with a fast model like gpt-4.1
				default_agent = "plan", -- plan ensure no file modifications by default
				instructions = nil, -- Use built-in instructions if nil
			},
		})
	end,
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				anti_conceal = { enabled = false },
				file_types = { "markdown", "opencode_output" },
			},
			ft = { "markdown", "Avante", "copilot-chat", "opencode_output" },
		},
		-- Optional, for file mentions and commands completion, pick only one
		-- "saghen/blink.cmp",
		"hrsh7th/nvim-cmp",

		-- Optional, for file mentions picker, pick only one
		-- "folke/snacks.nvim",
		"nvim-telescope/telescope.nvim",
		-- 'ibhagwan/fzf-lua',
		-- 'nvim_mini/mini.nvim',
	},
}
