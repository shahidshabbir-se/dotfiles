return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>fm",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
      typescript = { "biome", "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
      json = { "biome", "prettierd", "prettier", stop_after_first = true },
      jsonc = { "biome", "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      html = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      rust = { "rustfmt" },
      nix = { "nixfmt" },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
  config = function(_, opts)
    local conform = require("conform")
    conform.setup(opts)

    -- Auto-format on paste (Normal mode 'p' and 'P')
    local function paste_and_format(paste_cmd)
      return function()
        vim.cmd("normal! " .. paste_cmd)
        local start_line = vim.api.nvim_buf_get_mark(0, "[")[1]
        local end_line = vim.api.nvim_buf_get_mark(0, "]")[1]
        if start_line > 0 and end_line > 0 and start_line <= end_line then
          conform.format({
            range = {
              start = { start_line, 0 },
              ["end"] = { end_line, 0 },
            },
            async = true,
            lsp_fallback = true,
          })
        end
      end
    end

    vim.keymap.set("n", "p", paste_and_format("p"), { desc = "Paste and Auto-Format" })
    vim.keymap.set("n", "P", paste_and_format("P"), { desc = "Paste before and Auto-Format" })
  end,
}
