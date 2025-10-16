---@type NvPluginSpec
return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  opts = function()
    local nvlsp = require("nvchad.configs.lspconfig")
    return {
      on_attach = nvlsp.on_attach,
      on_init = nvlsp.on_init,
      capabilities = nvlsp.capabilities,
      settings = {
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",
        expose_as_code_action = {},
        tsserver_file_preferences = {
          includeCompletionsForModuleExports = true,
          includeCompletionsWithInsertText = true,
          includeCompletionsForImports = true,
          includeCompletionsWithSnippetText = true,
          allowIncompleteCompletions = true,
          includeAutomaticOptionalChainCompletions = true,
          includeCompletionsForClassMembers = true,
          includeCompletionsForClassMemberSnippets = true,
          includeCompletionsForJsxTags = true,
          includeCompletionsForJson = true,
          includeCompletionsForJsDocComments = true,
          autoImportFileExcludePatterns = {
            "node_modules",
            "@types/*",
          },
        },
        tsserver_max_memory = "auto",
        tsserver_plugins = {
          "@styled/typescript-styled-plugin",
        },
        jsx_close_tag = {
          enable = true,
          filetypes = { "javascriptreact", "typescriptreact" },
        },
      },
    }
  end,
}