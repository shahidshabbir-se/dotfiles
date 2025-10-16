return {
	-- Overrides
	{ import = "plugins.override.telescope" },
	{ import = "plugins.override.blankline" },
	{ import = "plugins.override.nvim-web-devicons" },
	{ import = "plugins.override.nvim-tree" },
	{ import = "plugins.override.conform" },

	-- Specs
	{ import = "plugins.spec.tiny-code-action" },
	{ import = "plugins.spec.typescript-tools" },
	{ import = "plugins.spec.ts-autotag" },
	{ import = "plugins.spec.vim-astro" },
	{ import = "plugins.spec.tailwind-fold" },
	{ import = "plugins.spec.mini-indentoscope" },
	{ import = "plugins.spec.copilot" },
	{ import = "plugins.spec.markview" },
	{ import = "plugins.spec.debugging" },
	{ import = "plugins.spec.treesitter" },
	{ import = "plugins.spec.auto-save" },
	{ import = "plugins.spec.auto-session" },
	{ import = "plugins.spec.mini-animate" },
	{ import = "plugins.spec.nvim-cmp" },
	{ import = "plugins.spec.grug-far" },
	-- { import = "plugins.spec.noice" },
	{ import = "plugins.spec.trouble" },
	{ import = "plugins.spec.undo-tree" },
	{ import = "plugins.spec.vim-visual-multi" },
	{ import = "plugins.spec.cloak" },
	{ import = "plugins.spec.sql" },
	{ import = "plugins.spec.snacks" },

	-- Plugins
	{ import = "plugins.local.js-playground" },

	-- LSP & Mason
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("configs.lspconfig")
		end,
	},
	{
		"b0o/SchemaStore.nvim",
		lazy = true,
		version = false,
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

	-- Editor Enhancements
	{
		"folke/which-key.nvim",
		config = function()
			local which_key = require("which-key")
			which_key.setup({
				preset = "modern",
			})
		end,
	},
	{
		"echasnovski/mini.move",
		event = "VeryLazy",
		config = function()
			require("configs.mini-move")
		end,
	},

	-- UI Enhancements
	{
		"folke/todo-comments.nvim",
		event = "BufReadPre",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},

	-- Linting & Formatting
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost", "InsertLeave" },
		config = function()
			local lint = require("lint")
			local ts_config = require("lang.typescript")

			lint.linters_by_ft = {
				dockerfile = { "hadolint" },
				sql = { "sqlfluff" },
				python = { "ruff", "mypy" },
			}

			-- Add TypeScript/Node.js linters
			if ts_config.lint then
				lint.linters_by_ft = vim.tbl_deep_extend("force", lint.linters_by_ft, ts_config.lint.linters_by_ft)
			end

			lint.linters.sqlfluff = {
				args = {
					"lint",
					"--format=json",
					"--dialect=postgres",
				},
			}

			lint.linters.mypy = {
				cmd = "mypy", -- The command to run mypy
				stdin = false, -- No stdin input for mypy
				stream = "both", -- Capture both stdout and stderr
				ignore_exitcode = true, -- Ignore exit code
				args = {
					"--show-column-numbers",
					"--show-error-end",
					"--hide-error-context",
					"--no-color-output",
					"--no-error-summary",
					"--no-pretty",
				},
				-- Custom parser to parse the output of mypy
				parser = require("lint.parser").from_pattern(
					-- Regex pattern to match the output format
					"([^:]+):(%d+):(%d+):(%d+):(%d+): (%a+): (.*) %[(%a[%a-]+)%]",
					-- Groupings from the regex pattern
					{ "file", "lnum", "col", "end_lnum", "end_col", "severity", "message", "code" },
					-- Severity mapping for diagnostics
					{
						error = vim.diagnostic.severity.ERROR,
						warning = vim.diagnostic.severity.WARN,
						note = vim.diagnostic.severity.HINT,
					},
					-- Additional source information for the diagnostics
					{ ["source"] = "mypy" },
					-- Offset adjustments for the end column
					{ end_col_offset = 0 }
				),
			}

			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},

	-- Typing Speed Enhancement
	{
		"nvzone/typr",
		dependencies = "nvzone/volt",
		opts = {},
		cmd = { "Typr", "TyprStats" },
	},
}
