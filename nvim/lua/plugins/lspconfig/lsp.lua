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
    local lspconfig = require("lspconfig")
    local on_attach = function(client, buffer)
      require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
    end
    local capabilities = require("cmp_nvim_lsp").update_capabilities(
      vim.lsp.protocol.make_client_capabilities()
    )

    lspconfig.ts_ls.setup({
      on_attach = on_attach,
    })

    lspconfig.prismals.setup({
      on_attach = on_attach,
      settings = {
        prisma = {
          prismaFmtBinPath = "",
        },
      },
    })

    lspconfig.astro.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })

    lspconfig.tailwindcss.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      filetypes = { "html", "css", "typescriptreact", "typescript", "javascriptreact", "javascript", "astro" },
      root_dir = require("lspconfig.util").root_pattern(
        "tailwind.config.mjs",
        "tailwind.config.ts",
        "tailwind.config.js"
      ),
    })

    lspconfig.emmet_ls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      filetypes = {
        "html",
        "css",
        "typescriptreact",
        "javascriptreact",
        "vue",
        "svelte",
        "astro",
      },
      settings = {
        emmet = {
          html = { enable = true },
          css = { enable = true },
          typescriptreact = { enable = true },
          javascriptreact = { enable = true },
          vue = { enable = true },
          svelte = { enable = true },
        },
      },
    })

    lspconfig.pyright.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "workspace",
          },
        },
      },
    })

    require("mason-lspconfig").setup_handlers({
      ["ts_ls"] = function()
        require("typescript-tools").setup({})
      end,
    })

    -- lspconfig.eslint.setup({
    --   on_attach = on_attach,
    --   settings = {
    --     workingDirectories = { mode = "auto" },
    --   },
    -- })
  end,
}
