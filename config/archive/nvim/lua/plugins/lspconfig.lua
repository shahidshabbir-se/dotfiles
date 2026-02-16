return {
  "neovim/nvim-lspconfig",
  dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
  config = function()
    local langs = require("lang").langs

    local capabilities = {}
    local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if cmp_ok then
      capabilities = cmp_nvim_lsp.default_capabilities()
    end

    for _, lang in ipairs(langs) do
      if lang.lsp then
        for server_name, server_config in pairs(lang.lsp) do
          local config = vim.tbl_deep_extend("force", {
            capabilities = capabilities,
          }, server_config or {})
          
          -- Use vim.lsp.config to define the configuration first
          vim.lsp.config(server_name, config)
          -- Then enable it
          vim.lsp.enable(server_name)
        end
      end
    end
  end,
}
