-- lua/config/lualine.lua
local ok_theme, theme = pcall(require, "lualine.themes.auto")
if not ok_theme then return end

for _, mode in pairs({ "normal", "insert", "visual", "replace", "command", "inactive" }) do
  if theme[mode] and theme[mode].c then
    theme[mode].c.bg = "None"
  end
end

local function safe_require(mod)
  local ok, m = pcall(require, mod)
  return ok and m or nil
end

local function pretty_path()
  local path = vim.fn.fnamemodify(vim.fn.expand("%:."), ":~:.")
  return path == "" and "[No File]" or path
end

require("lualine").setup({
  options = {
    theme                = theme,
    -- component_separators = { left = "╱", right = "╲" },
    -- section_separators   = { left = "", right = "" },
    component_separators = { left = "●", right = "●" },
    section_separators   = { left = "", right = "" },
    globalstatus         = true,
    disabled_filetypes   = {
      statusline = { "dashboard", "NvimTree", "alpha", "starter", "snacks_dashboard" },
    },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = {
      { "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = " " } },
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      { pretty_path },
      {
        function()
          local winbar = require("lspsaga.symbol.winbar")
          return winbar and winbar.get_bar and winbar.get_bar() or ""
        end,
        cond = function()
          local winbar = require("lspsaga.symbol.winbar")
          return winbar and winbar.get_bar and winbar.get_bar() ~= nil
        end,
      },
    },
    lualine_x = {
      'copilot',
      {
        function()
          local dap = safe_require("dap")
          return dap and dap.status() ~= "" and ("  " .. dap.status()) or ""
        end,
        cond = function()
          local dap = safe_require("dap")
          return dap and dap.status() ~= ""
        end,
      },
    },
    lualine_y = {
      { "progress", separator = " ",                  padding = { left = 1, right = 0 } },
      { "location", padding = { left = 0, right = 1 } },
    },
    lualine_z = {
      function()
        return " " .. os.date("%R")
      end,
    },
  },
  extensions = {
    "nvim-tree",
    "fzf",
    "lazy",
    "trouble",
    "mason",
    "toggleterm",
    "nvim-dap-ui",
  },

})

-- Optional Trouble integration
if vim.g.trouble_lualine then
  local trouble = safe_require("trouble")
  if trouble then
    local symbols = trouble.statusline({
      mode = "symbols",
      groups = {},
      title = false,
      filter = { range = true },
      format = "{kind_icon}{symbol.name:Normal}",
      hl_group = "lualine_c_normal",
    })

    if symbols and symbols.get then
      table.insert(require("lualine").get_config().sections.lualine_c, {
        symbols.get,
        cond = function()
          return vim.b.trouble_lualine ~= false and symbols.has()
        end,
      })
    end
  end
end
