---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "tokyonight",
  transparency = true,
  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
    NvimTreeNormal = { bg = "NONE" },
    NvimTreeNormalNC = { bg = "NONE" },
    NeoTreeNormal = { bg = "NONE" },
    NeoTreeNormalNC = { bg = "NONE" },
    NvimTreeWinSeparator = { link = "WinSeparator" },
    NeoTreeWinSeparator = { link = "WinSeparator" },
    TbLineFill = { bg = "NONE" },
  },
}

M.ui = {
  transparency = true,
  cmp = {
    icons_left = true,
    style = "default",
    abbr_maxwidth = 60,
    format_colors = {
      tailwind = true,
      icon = "",
    },
  },
  statusline = {
    enabled = true,
    theme = "default",
    separator_style = "block",
    order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cursor", "cwd" },
    modules = nil,
  },
  tabufline = {
    enabled = true,
    lazyload = true,
    treeOffsetFt = "neo-tree",
    order = { "treeOffset", "buffers", "tabs" },
    bufwidth = 21,
    modules = {
      treeOffset = function()
        local api = vim.api
        local opts = require("nvconfig").ui.tabufline
        local w = 0
        for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
          if vim.bo[api.nvim_win_get_buf(win)].ft == opts.treeOffsetFt then
            w = api.nvim_win_get_width(win)
            break
          end
        end

        if w == 0 then
          return ""
        end

        local title = " 󰙅 Explorer "
        local title_len = vim.fn.strdisplaywidth(title)
        local left_padding = math.max(0, math.floor((w - title_len) / 2))
        local right_padding = math.max(0, w - title_len - left_padding)

        local pad_left = string.rep(" ", left_padding)
        local pad_right = string.rep(" ", right_padding)

        return "%#NvimTreeNormal#" .. pad_left .. "%#NvimTreeTitle#" .. title .. "%#NvimTreeNormal#" .. pad_right .. "%#NvimTreeWinSeparator#" .. "│"
      end,
    },
  },
}

M.nvdash = {
  load_on_startup = true,
  header = {
    "                            ",
    "     ▄▄         ▄ ▄▄▄▄▄▄▄   ",
    "   ▄▀███▄     ▄██ █████▀    ",
    "   ██▄▀███▄   ███           ",
    "   ███  ▀███▄ ███           ",
    "   ███    ▀██ ███           ",
    "   ███      ▀ ███           ",
    "   ▀██ █████▄▀█▀▄██████▄    ",
    "     ▀ ▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀▀▀   ",
    "                            ",
    "     Powered By  eovim    ",
    "                            ",
  },
  buttons = {
    { txt = "  Find File", keys = "ff", cmd = "Telescope find_files" },
    { txt = "  Recent Files", keys = "fo", cmd = "Telescope oldfiles" },
    { txt = "  Find Word", keys = "fw", cmd = "Telescope live_grep" },
    { txt = "  Themes", keys = "th", cmd = ":lua require('nvchad.themes').open()" },
    { txt = "  Mappings", keys = "ch", cmd = "NvCheatsheet" },
    { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
    {
      txt = function()
        local stats = require("lazy").stats()
        local ms = math.floor(stats.startuptime) .. " ms"
        return "  Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms
      end,
      hl = "NvDashFooter",
      no_gap = true,
    },
    { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
  },
}

M.term = {
  winopts = { number = false, relativenumber = false },
  sizes = { sp = 0.3, vsp = 0.2, ["bo sp"] = 0.3, ["bo vsp"] = 0.2 },
  float = {
    relative = "editor",
    row = 0.3,
    col = 0.25,
    width = 0.5,
    height = 0.4,
    border = "single",
  },
}

M.lsp = { signature = true }

M.cheatsheet = {
  theme = "simple",
  excluded_groups = { "terminal (t)", "autopairs", "Nvim", "Opens" },
}

M.colorify = {
  enabled = true,
  mode = "virtual",
  virt_text = " ",
  highlight = { hex = true, lspvars = true },
}

return M
