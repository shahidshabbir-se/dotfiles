local cmp = require("cmp")
local lspkind = require("lspkind")

-- Merge codicons with custom icons
local icons = vim.tbl_extend("force", lspkind.presets.codicons, {
	Supermaven = "	",
	Copilot = "",
})

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	window = {
		completion = cmp.config.window.bordered({
			-- border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }, -- correct order!
			border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }, -- rounded border
			side_padding = 0,
			col_offset = 0,
			max_width = 63,
			max_height = 7,
			winhighlight = "normal:normal,floatborder:floatborder,cursorline:pmenusel,search:none",
		}),
		documentation = cmp.config.window.bordered({
			-- border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }, -- square border
			border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }, -- rounded border
			winhighlight = "normal:normal,floatborder:floatborder,cursorline:pmenusel,search:none",
			side_padding = 0,
			max_width = 60,
			max_height = 40,
		}),
	},
	mapping = cmp.mapping.preset.insert({
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
	}),
	formatting = {
		format = function(entry, vim_item)
			vim_item = require("tailwind-tools.cmp").lspkind_format(entry, vim_item)
			-- Inject custom kinds based on source
			if entry.source.name == "copilot" then
				vim_item.kind = "Copilot"
			elseif entry.source.name == "supermaven" then
				vim_item.kind = "Supermaven"
			end

			local kind = vim_item.kind
			local icon = icons[kind] or ""

			vim_item.kind = icon .. " " .. kind
			-- vim_item.kind_hl_group = "CmpItemKind" .. kind
			vim_item.abbr_hl_group = "CmpItemAbbr"
			vim_item.menu_hl_group = "CmpItemMenu"

			return vim_item
		end,
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp", group_index = 1, priority = 100 },
		{ name = "copilot", group_index = 2, priority = 300 },
		{ name = "supermaven", group_index = 2, priority = 300 },
		{ name = "luasnip", group_index = 3, priority = 500 },
		{ name = "path", group_index = 4, priority = 600 },
	}, {
		{ name = "buffer" },
	}),
})
