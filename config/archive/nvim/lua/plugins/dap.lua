return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        opts = {
          icons = { expanded = "󰅀", collapsed = "󰅂", current_frame = "󰁔" },
          controls = {
            icons = {
              pause = "󰏤",
              play = "󰐊",
              step_into = "󰆹",
              step_over = "󰆷",
              step_out = "󰆸",
              step_back = "󰏎",
              run_last = "󰐗",
              terminate = "󰓛",
              disconnect = "󰅚",
            },
          },
        },
        config = function(_, opts)
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)

          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          enabled = true,
          enable_commands = true,
          highlight_changed_variables = true,
          highlight_new_as_changed = false,
          show_stop_reason = true,
          commented = false,
        },
      },
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim" },
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
          automatic_installation = true,
          handlers = {},
          ensure_installed = {
            "codelldb", -- Rust / C / C++
            "js-debug-adapter", -- Full-stack JS/TS / React / Next.js / Node
          },
        },
      },
    },
    keys = {
      {
        "<leader>db",
        function() require("dap").toggle_breakpoint() end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          vim.ui.input({ prompt = "Breakpoint condition: " }, function(input)
            if input and #input > 0 then
              require("dap").set_breakpoint(input)
            end
          end)
        end,
        desc = "Conditional Breakpoint",
      },
      {
        "<leader>dc",
        function() require("dap").continue() end,
        desc = "Continue / Start Debugger",
      },
      {
        "<leader>di",
        function() require("dap").step_into() end,
        desc = "Step Into",
      },
      {
        "<leader>do",
        function() require("dap").step_over() end,
        desc = "Step Over",
      },
      {
        "<leader>dO",
        function() require("dap").step_out() end,
        desc = "Step Out",
      },
      {
        "<leader>dr",
        function() require("dap").repl.toggle() end,
        desc = "Toggle REPL",
      },
      {
        "<leader>dl",
        function() require("dap").run_last() end,
        desc = "Run Last Debug Session",
      },
      {
        "<leader>du",
        function() require("dapui").toggle() end,
        desc = "Toggle DAP UI",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
          require("dapui").close()
        end,
        desc = "Terminate Debugger",
      },
    },
    config = function()
      local dap = require("dap")

      -- Clean Nerd Font Icons for Breakpoints & Execution Pointer
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "󰍡", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "󰁔", texthl = "DiagnosticSignHint", linehl = "DapStoppedLine", numhl = "" })

      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      -- Configurations for Full-Stack JS/TS (Node.js & Web)
      for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch Current File (Node.js)",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Node Process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
  },
}
