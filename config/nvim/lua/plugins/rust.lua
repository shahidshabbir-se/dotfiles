return {
  "mrcjkb/rustaceanvim",
  version = "^5",
  ft = { "rust" },
  opts = {
    server = {
      on_attach = function(client, bufnr)
        -- Keybinds specific to Rust
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "<leader>cR", function() vim.cmd.RustLsp("codeAction") end, "Rust Code Action")
        map("n", "<leader>dr", function() vim.cmd.RustLsp("debuggables") end, "Rust Debuggables")
        map("n", "<leader>rr", function() vim.cmd.RustLsp("runnables") end, "Rust Runnables")
        map("n", "<leader>rd", function() vim.cmd.RustLsp("renderDiagnostic") end, "Render Rust Diagnostic")
        map("n", "<leader>rc", function() vim.cmd.RustLsp("openCargo") end, "Open Cargo.toml")
        map("n", "<leader>rp", function() vim.cmd.RustLsp("parentModule") end, "Parent Module")
      end,
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
      default_settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
            buildScripts = { enable = true },
          },
          checkOnSave = {
            command = "clippy",
            extraArgs = { "--no-deps" },
          },
          procMacro = {
            enable = true,
            ignored = {
              ["async-trait"] = { "async_trait" },
              ["napi-derive"] = { "napi" },
              ["async-recursion"] = { "async_recursion" },
            },
          },
          inlayHints = {
            bindingModeHints = { enable = false },
            chainingHints = { enable = true },
            closingBraceHints = { enable = true, minLines = 25 },
            closureReturnTypeHints = { enable = "never" },
            lifetimeElisionHints = { enable = "never" },
            parameterHints = { enable = true },
            typeHints = { enable = true },
          },
        },
      },
    },
  },
  config = function(_, opts)
    vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts)
  end,
}
