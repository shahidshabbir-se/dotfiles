
local go = require("lang.go")
local templ = require("lang.templ")
local on_attach = function(client, bufnr)
  -- Attach tailwindcss-colors
  -- if client.name == "tailwindcss" then
  --   require("tailwindcss-colors").buf_attach(bufnr)
  -- end

  require("keymaps.lspconfig").on_attach(client, bufnr)
end
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.templ" },
  callback = function() vim.lsp.buf.format({ async = false }) end,
})

vim.lsp.config.cssls = {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "templ" },
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    css = {
      validate = true,
      lint = {
        unknownAtRules = "ignore",
      },
    },
    scss = {
      validate = true,
      lint = {
        unknownAtRules = "ignore",
      },
    },
    less = {
      validate = true,
      lint = {
        unknownAtRules = "ignore",
      },
    },
  },
}


vim.lsp.config.lua_ls = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- lspconfig.rust_analyzer.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
-- })

vim.lsp.config.gopls = vim.tbl_deep_extend("force", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  on_attach = on_attach,
  capabilities = capabilities,
}, go.lsp.gopls)



vim.lsp.config.templ = vim.tbl_deep_extend("force", {
  on_attach = on_attach,
  capabilities = capabilities,
}, templ.lsp.templ)

-- require("lspconfig").tailwindcss.setup({
--   on_attach = function(client, bufnr)
--     if client.name == "tailwindcss" then
--       require("tailwindcss-colors").buf_attach(bufnr)
--     end
--     on_attach(client, bufnr) -- your existing on_attach
--   end,
--   capabilities = capabilities,
--   filetypes = { "templ", "svelte", "javascriptreact", "typescriptreact", "astro", "javascript", "typescript" },
--   settings = {
--     tailwindCSS = {
--       experimental = {
--         classRegex = {
--           'class="([^"]*)"',     -- HTML-style
--           "class='([^']*)'",     -- single quotes
--           'className="([^"]*)"', -- React JSX
--           "className='([^']*)'", -- React JSX single quotes
--         },
--       },
--       includeLanguages = {
--         templ = "html", -- Treat `.templ` files as HTML
--       },
--     },
--   },
-- })

vim.lsp.config.rnix = {
  cmd = { "rnix-lsp" },
  filetypes = { "nix" },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- lspconfig.ts_ls.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
-- })

vim.lsp.config.html = {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html", "templ" },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- lspconfig.htmx.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
--   filetypes = { "html", "templ" },
-- })
--
