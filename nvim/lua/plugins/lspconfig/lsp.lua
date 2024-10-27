-- lsp.lua
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "pmizio/typescript-tools.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
    },
  },
  config = function()
    require("lspconfig").ts_ls.setup({
      on_attach = function(client, buffer)
        require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
      end,
    })

    require("lspconfig").prismals.setup({
      on_attach = function(client, buffer)
        require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
      end,
      settings = {
        prisma = {
          prismaFmtBinPath = "", -- Leave this empty to use default Prisma formatter
        },
      },
    })

    -- Astro Language Server setup
    require("lspconfig").astro.setup({
      on_attach = function(client, buffer)
        require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
      end,
      capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
    })

    -- Tailwind CSS Language Server setup
    require("lspconfig").tailwindcss.setup({
      on_attach = function(client, buffer)
        require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
      end,
      capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
      filetypes = { "html", "css", "typescriptreact", "typescript", "javascriptreact", "javascript", "astro" },
      root_dir = require("lspconfig.util").root_pattern("tailwind.config.mjs", "tailwind.config.js"), -- Include both mjs and js
    })

    require("lspconfig").emmet_ls.setup({
      on_attach = function(client, buffer)
        require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
      end,
      capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
      filetypes = {
        "html",
        "css",
        "typescriptreact",
        "typescript",
        "javascriptreact",
        "javascript",
        "vue",
        "svelte",
        "astro",
      },
      settings = {
        emmet = {
          html = { enable = true },
          css = { enable = true },
          javascript = { enable = true },
          typescript = { enable = true },
          typescriptreact = { enable = true },
          javascriptreact = { enable = true },
          vue = { enable = true },
          svelte = { enable = true },
        },
      },
    })

    -- require("lspconfig").eslint.setup({
    --   on_attach = function(client, buffer)
    --     require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
    --   end,
    --   settings = {
    --     workingDirectories = { mode = "auto" },
    --   },
    -- })

    require("mason-lspconfig").setup_handlers({
      ["ts_ls"] = function()
        require("typescript-tools").setup({})
      end,
    })
  end,
}
