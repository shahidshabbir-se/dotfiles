local go = require("lang.go")
local templ = require("lang.templ")
local lspconfig = require("lspconfig")
local on_attach = require("keymaps.lspconfig").on_attach
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
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
        disable = { "different-requires" },
      },
    },
  },
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

-- lspconfig.tailwindcss.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
--   filetypes = { "templ", "astro", "javascript", "typescript", "react" },
--   settings = {
--     tailwindCSS = {
--       includeLanguages = {
--         templ = "html",
--       },
--     },
--   },
-- })

lspconfig.rnix.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

lspconfig.ts_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

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
