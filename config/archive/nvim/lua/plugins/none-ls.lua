return {
  "nvimtools/none-ls.nvim", -- replacement for null-ls.nvim
  dependencies = { "nvim-lua/plenary.nvim", "williamboman/mason.nvim" },
  config = function()
    local langs = require("lang").langs

    local none_ls_ok, none_ls = pcall(require, "none-ls")
    if not none_ls_ok then return end

    local sources = {}

    for _, lang in ipairs(langs) do
      -- Setup formatters
      if lang.formatters then
        for ft, fmt_list in pairs(lang.formatters) do
          for _, fmt in ipairs(fmt_list) do
            local formatter = none_ls.builtins.formatting[fmt]
            if formatter then
              table.insert(sources, formatter)
            else
              vim.notify("Formatter not found: " .. fmt, vim.log.levels.WARN)
            end
          end
        end
      end

      -- Setup linters
      if lang.linters then
        for ft, lints in pairs(lang.linters) do
          for _, lint in ipairs(lints) do
            local linter = none_ls.builtins.diagnostics[lint]
            if linter then
              table.insert(sources, linter)
            else
              vim.notify("Linter not found: " .. lint, vim.log.levels.WARN)
            end
          end
        end
      end
    end

    none_ls.setup({ sources = sources })
  end,
}
