---@type ChadrcConfig
local M = {}

-- Right-side pills: same two-shade wedge as mode, but  toward the center.
local function right_pill(id, color_hl, icon, text, prev_bg)
  local color = vim.api.nvim_get_hl(0, { name = color_hl, link = false })
  local grey = vim.api.nvim_get_hl(0, { name = "St_NormalModeSep", link = false })
  local file = vim.api.nvim_get_hl(0, { name = "St_file", link = false })
  if not (color.bg and grey.bg) then
    return icon .. " " .. text
  end

  vim.api.nvim_set_hl(0, id .. "_sep", { fg = color.bg, bg = prev_bg or "NONE" })
  vim.api.nvim_set_hl(0, id .. "_icon", { fg = color.fg, bg = color.bg, bold = true })
  vim.api.nvim_set_hl(0, id .. "_iconSep", { fg = grey.bg, bg = color.bg })
  vim.api.nvim_set_hl(0, id .. "_empty", { fg = file.bg, bg = grey.bg })
  vim.api.nvim_set_hl(0, id .. "_text", { fg = color.bg, bg = file.bg })

  local seps = require("nvchad.stl.utils").separators[require("nvconfig").ui.statusline.separator_style]
  return "%#"
    .. id
    .. "_sep#"
    .. seps.left
    .. "%#"
    .. id
    .. "_icon#"
    .. icon
    .. "%#"
    .. id
    .. "_iconSep#"
    .. seps.left
    .. "%#"
    .. id
    .. "_empty#"
    .. seps.left
    .. "%#"
    .. id
    .. "_text#"
    .. " "
    .. text
    .. " "
end

M.base46 = {
  theme = "tokyonight",
  transparency = true,
  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
    NotifyBackground = { bg = "NONE" },
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
    theme = "default",         -- default/vscode/vscode_colored/minimal
    -- default/round/block/arrow separators work only for default statusline theme
    separator_style = "arrow", -- round and block will work for minimal theme only
    order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cursor", "cwd" },
    modules = {
      lsp = function()
        local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
        local clients = vim.lsp.get_clients { bufnr = buf }
        if #clients == 0 then
          return ""
        end

        local skip = {
          tailwindcss = true,
          eslint = true,
          emmet_ls = true,
          emmet_language_server = true,
        }
        local name
        for _, c in ipairs(clients) do
          if not skip[c.name] then
            name = c.name
            break
          end
        end
        name = name or clients[1].name

        return right_pill("St_lsp", "St_NormalMode", "󰒋 ", name)
      end,
      cursor = function()
        local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
        local prev = #vim.lsp.get_clients { bufnr = buf } > 0
            and vim.api.nvim_get_hl(0, { name = "St_file", link = false }).bg
          or "NONE"
        return right_pill("St_pos", "St_pos_icon", " ", "%l/%v", prev)
      end,
      cwd = function()
        if vim.o.columns <= 85 then
          return ""
        end
        local name = vim.uv.cwd()
        name = name and (name:match "([^/\\]+)[/\\]*$" or name) or ""
        local prev = vim.api.nvim_get_hl(0, { name = "St_file", link = false }).bg
        return right_pill("St_cwd", "St_cwd_icon", "󰉋 ", name, prev)
      end,
    },
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

        return "%#NvimTreeNormal#" ..
            pad_left ..
            "%#NvimTreeTitle#" .. title .. "%#NvimTreeNormal#" .. pad_right .. "%#NvimTreeWinSeparator#" .. "│"
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
