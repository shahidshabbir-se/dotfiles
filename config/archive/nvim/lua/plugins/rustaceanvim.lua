return {
  "mrcjkb/rustaceanvim",
  version = "^5", -- Recommended
  lazy = false, -- This plugin is already lazy
  config = function()
    vim.g.rustaceanvim = function()
      local mason_registry = require('mason-registry')
      local codelldb_path, liblldb_path
      
      if mason_registry.is_installed("codelldb") then
        local codelldb = mason_registry.get_package("codelldb")
        local extension_path
        
        -- Try to get path from mason, otherwise fallback to standard path
        if codelldb.get_install_path then
          extension_path = codelldb:get_install_path() .. "/extension/"
        else
          extension_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
        end
        
        codelldb_path = extension_path .. "adapter/codelldb"
        liblldb_path = extension_path .. "lldb/lib/liblldb.so"
        if vim.fn.has('mac') == 1 then
            liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
        end
      else
        vim.notify("codelldb not found. Please install it via Mason.", vim.log.levels.WARN)
      end

      local dap_config = {}
      if codelldb_path and liblldb_path then
        dap_config = {
          adapter = require('rustaceanvim.config').get_codelldb_adapter(codelldb_path, liblldb_path),
        }
      end

      return {
        server = {
          on_attach = function(client, bufnr)
              -- Add rust-specific keymaps here if needed
          end,
          default_settings = {
            -- rust-analyzer language server configuration
            ['rust-analyzer'] = {
              cargo = {
                  allFeatures = true,
                  loadOutDirsFromCheck = true,
                  buildScripts = {
                      enable = true,
                  },
              },
              -- Use 'check' for configuration, 'checkOnSave' is just a boolean
              checkOnSave = true,
              check = {
                  command = "clippy",
                  extraArgs = { "--no-deps" },
                  features = "all",
              },
              procMacro = {
                  enable = true,
                  ignored = {
                      ["async-trait"] = { "async_trait" },
                      ["napi-derive"] = { "napi" },
                      ["async-recursion"] = { "async_recursion" },
                  },
              },
            },
          },
        },
        dap = dap_config,
      }
    end
  end
}
