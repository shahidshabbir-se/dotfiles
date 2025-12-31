local M = {}

function M.setup()
  local luasnip = require("luasnip")

  luasnip.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
    enable_autosnippets = true,
  })

  vim.schedule(function()
    vim.tbl_map(function(type)
      local loader = "luasnip.loaders.from_" .. type
      local ok, mod = pcall(require, loader)
      if ok and mod.lazy_load then
        mod.lazy_load()
      end
    end, { "vscode", "snipmate", "lua" })
  end)

  -- Extend html snippets to other filetypes
  luasnip.filetype_extend("javascriptreact", { "html" })
  luasnip.filetype_extend("typescriptreact", { "html" })
  luasnip.filetype_extend("svelte", { "html" })

  -- Extend tailwindcss snippets to web frameworks
  luasnip.filetype_extend("javascriptreact", { "tailwindcss" })
  luasnip.filetype_extend("typescriptreact", { "tailwindcss" })
  luasnip.filetype_extend("svelte", { "tailwindcss" })
  luasnip.filetype_extend("vue", { "tailwindcss" })
  luasnip.filetype_extend("astro", { "tailwindcss" })
  luasnip.filetype_extend("html", { "tailwindcss" })

  -- Global snippets
  luasnip.filetype_extend("all", { "_" })
end

return M
