
local go = require("lang.go")
local templ = require("lang.templ")
local lspconfig = require("lspconfig")
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

lspconfig.cssls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "css", "templ" },
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
})


lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- lspconfig.rust_analyzer.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
-- })

lspconfig.gopls.setup(vim.tbl_deep_extend("force", {
  on_attach = on_attach,
  capabilities = capabilities,
}, go.lsp.gopls))



lspconfig.templ.setup(vim.tbl_deep_extend("force", {
  on_attach = on_attach,
  capabilities = capabilities,
}, templ.lsp.templ))

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

-- lspconfig.rnix.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
-- })

-- lspconfig.ts_ls.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
-- })

lspconfig.html.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "html", "templ" },
})

-- lspconfig.htmx.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
--   filetypes = { "html", "templ" },
-- })
--
