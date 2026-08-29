return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    -- Keymaps on LSP attach
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set("n", "<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, opts)
      end,
    })

    -- Diagnostic styling
    vim.diagnostic.config({
      virtual_text = {
        spacing = 4,
        prefix = "●",
      },
      severity_sort = true,
      float = {
        border = "rounded",
        source = "always",
      },
    })

    -- Diagnostic signs
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- Completion capabilities
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lspconfig = require("lspconfig")

    -- Load server definitions from configs/servers.lua
    local all_servers = require("configs.servers")

    -- Filter to only enabled servers, strip the `enabled` key before passing to lspconfig
    local enabled_servers = {}
    for name, config in pairs(all_servers) do
      if config.enabled ~= false then
        local cfg = vim.deepcopy(config)
        cfg.enabled = nil -- remove the toggle key before passing to lspconfig
        enabled_servers[name] = cfg
      end
    end

    -- Build handlers dynamically
    local handlers = {
      -- Default handler: servers with no extra settings
      function(server_name)
        lspconfig[server_name].setup({ capabilities = capabilities })
      end,
    }

    for server, config in pairs(enabled_servers) do
      if next(config) ~= nil then
        handlers[server] = function()
          lspconfig[server].setup(vim.tbl_deep_extend("force", {
            capabilities = capabilities,
          }, config))
        end
      end
    end

    require("mason-lspconfig").setup({
      ensure_installed = vim.tbl_keys(enabled_servers),
      handlers = handlers,
    })
  end,
}
