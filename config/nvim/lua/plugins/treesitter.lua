return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- Install parsers based on lang configuration
    local ok, lang_mod = pcall(require, "lang")
    if ok and lang_mod and lang_mod.langs then
      local parsers_to_install = {}
      for _, lang in ipairs(lang_mod.langs) do
        if type(lang) == "table" and lang.treesitter then
          for _, parser in ipairs(lang.treesitter) do
            table.insert(parsers_to_install, parser)
          end
        end
      end

      -- Install parsers using the new API
      if #parsers_to_install > 0 then
        vim.schedule(function()
          local ts_install = require("nvim-treesitter.install")
          for _, parser in ipairs(parsers_to_install) do
            if not vim.list_contains(require("nvim-treesitter").get_installed(), parser) then
              pcall(ts_install.install, parser)
            end
          end
        end)
      end
    end

    -- Enable treesitter-based highlighting and indentation (new API)
    vim.treesitter.language.register('markdown', 'mdx')
  end,
  init = function()
    -- Enable treesitter highlight and indent (done via vim options now)
    vim.g.skip_ts_context_commentstring_module = true
  end,
}
