return {
  -- Disable nvim-dap-ui (conflicts with debugmaster)
  { "rcarriga/nvim-dap-ui", enabled = false },
  { "theHamsta/nvim-dap-virtual-text", enabled = false },

  -- debugmaster.nvim: DEBUG mode + dap-ui alternative
  {
    "MironPascalCaseFan/debugmaster.nvim",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      local dm = require("debugmaster")

      -- Toggle debug mode with <leader>d
      vim.keymap.set({ "n", "v" }, "<leader>dd", dm.mode.toggle, { nowait = true, desc = "Toggle Debug Mode" })
      vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

      -- Optional: track debug mode for statusline
      vim.api.nvim_create_autocmd("User", {
        pattern = "DebugModeChanged",
        callback = function(args)
          vim.g.debugmaster_active = args.data.enabled
        end,
      })

      local dap = require("dap")

      -----------------------------------------------------------
      -- JS/TS debugging (vscode-js-debug via mason)
      -----------------------------------------------------------
      -- mason installs js-debug-adapter to this path
      local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"

      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { js_debug_path .. "/js-debug/src/dapDebugServer.js", "${port}" },
        },
      }

      dap.adapters["pwa-chrome"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { js_debug_path .. "/js-debug/src/dapDebugServer.js", "${port}" },
        },
      }

      -- Shared configurations for JS/TS filetypes
      local js_configs = {
        -- Node: launch current file
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file (Node)",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        -- Node: attach to running process
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to Node process",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
        -- Chrome: debug frontend app
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Launch Chrome (localhost:3000)",
          url = "http://localhost:3000",
          webRoot = "${workspaceFolder}",
        },
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Launch Chrome (localhost:5173)",
          url = "http://localhost:5173",
          webRoot = "${workspaceFolder}",
        },
      }

      for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte" }) do
        dap.configurations[lang] = js_configs
      end

      -----------------------------------------------------------
      -- Rust / C / C++ debugging (codelldb via mason)
      -- LazyVim lang.rust extra already configures codelldb,
      -- but we add explicit configs as fallback
      -----------------------------------------------------------
      if not dap.configurations.rust or #dap.configurations.rust == 0 then
        local codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"

        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = {
            command = codelldb_path,
            args = { "--port", "${port}" },
          },
        }

        dap.configurations.rust = {
          {
            type = "codelldb",
            request = "launch",
            name = "Launch (Cargo build)",
            program = function()
              -- Build first, then pick the binary
              vim.fn.system("cargo build")
              local bin = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
              return bin
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
          },
        }
      end
    end,
  },

  -- Ensure DAP adapters are installed via mason
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = { "js", "codelldb" },
    },
  },
}
