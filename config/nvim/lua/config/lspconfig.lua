local go = require("lang.go")
local templ = require("lang.templ")

local on_attach = function(client, bufnr)
  require("keymaps.lspconfig").on_attach(client, bufnr)
end
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.templ" },
  callback = function() vim.lsp.buf.format({ async = false }) end,
})

-- CSS Language Server
vim.lsp.config.cssls = {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "templ" },
  root_markers = { "package.json", ".git" },
  settings = {
    css = {
      validate = true,
      lint = { unknownAtRules = "ignore" },
    },
    scss = {
      validate = true,
      lint = { unknownAtRules = "ignore" },
    },
    less = {
      validate = true,
      lint = { unknownAtRules = "ignore" },
    },
  },
}

-- Lua Language Server
vim.lsp.config.lua_ls = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
}

-- Go Language Server
local gopls_config = vim.tbl_deep_extend("force", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
}, go.lsp.gopls)
vim.lsp.config.gopls = gopls_config

-- Templ Language Server
local templ_config = vim.tbl_deep_extend("force", {
  filetypes = { "templ" },
  root_markers = { "go.mod", ".git" },
}, templ.lsp.templ)
vim.lsp.config.templ = templ_config

-- HTML Language Server
vim.lsp.config.html = {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html", "templ" },
  root_markers = { "package.json", ".git" },
}

-- Tailwind CSS Language Server
vim.lsp.config.tailwindcss = {
  cmd = { "tailwindcss-language-server", "--stdio" },
  filetypes = { "templ", "svelte", "javascriptreact", "typescriptreact", "astro", "javascript", "typescript", "html", "css" },
  root_markers = { "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "package.json", ".git" },
  settings = {
    tailwindCSS = {
      experimental = {
        classRegex = {
          'class="([^"]*)"',
          "class='([^']*)'",
          'className="([^"]*)"',
          "className='([^']*)'",
        },
      },
      includeLanguages = {
        templ = "html",
      },
    },
  },
}

-- Enable LSP servers (typescript-tools plugin handles TypeScript LSP)
vim.lsp.enable({ "cssls", "lua_ls", "gopls", "templ", "html", "tailwindcss" })

-- Set capabilities and on_attach for all servers
for _, server in ipairs({ "cssls", "lua_ls", "gopls", "templ", "html", "tailwindcss" }) do
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == server then
        on_attach(client, args.buf)
      end
    end,
  })
end
