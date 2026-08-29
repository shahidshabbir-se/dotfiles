-- =============================================================================
-- LSP Server Configuration
-- =============================================================================
-- To disable a server: set  enabled = false
-- To enable  a server: set  enabled = true
-- Mason will only install servers that are enabled.
-- =============================================================================

return {
  -- ── Lua ────────────────────────────────────────────────────────────────────
  lua_ls = {
    enabled = true,
    settings = {
      Lua = {
        diagnostics = { globals = { "vim", "Snacks" } },
        workspace = {
          checkThirdParty = false,
        },
        telemetry = { enable = false },
        completion = { callSnippet = "Replace" },
      },
    },
  },

  -- ── Rust (Handled by rustaceanvim in lua/plugins/rust.lua) ─────────────────
  rust_analyzer = {
    enabled = false,
  },

  -- ── TypeScript / JavaScript / React / Next.js ──────────────────────────────
  ts_ls = {
    enabled = true,
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        suggest = { completeFunctionCalls = true },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        suggest = { completeFunctionCalls = true },
      },
    },
  },

  -- ── ESLint ─────────────────────────────────────────────────────────────────
  eslint = {
    enabled = true,
    settings = {
      workingDirectories = { mode = "auto" },
    },
  },

  -- ── Tailwind CSS ───────────────────────────────────────────────────────────
  tailwindcss = {
    enabled = true,
    settings = {
      tailwindCSS = {
        experimental = {
          classRegex = {
            { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" },
            { "cx\\(([^)]*)\\)",  "[\"'`]([^\"'`]*)[\"'`]" },
            { "cn\\(([^)]*)\\)",  "[\"'`]([^\"'`]*)[\"'`]" },
            { "clsx\\(([^)]*)\\)","[\"'`]([^\"'`]*)[\"'`]" },
          },
        },
      },
    },
  },

  -- ── HTML & CSS ─────────────────────────────────────────────────────────────
  html = {
    enabled = true,
    filetypes = { "html", "templ" },
  },
  cssls = { enabled = true },

  -- ── JSON & YAML ────────────────────────────────────────────────────────────
  jsonls = {
    enabled = true,
    settings = {
      json = { validate = { enable = true } },
    },
  },
  yamlls = {
    enabled = true,
    settings = {
      yaml = { keyOrdering = false },
    },
  },

  -- ── DevOps / Infra ─────────────────────────────────────────────────────────
  dockerls = { enabled = true },
  docker_compose_language_service = { enabled = true },
  nil_ls   = { enabled = true }, -- Nix Language Server
  bashls   = { enabled = true },

  -- ── Database ───────────────────────────────────────────────────────────────
  prismals = { enabled = true },
}
