vim.api.nvim_set_hl(0, "LineNr", { fg = "#aaaaaa" })
vim.api.nvim_set_hl(0, "Comment", { italic = true })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#7AA2F7", fg = "#1e1e2e", bold = true })

vim.api.nvim_set_hl(0, "CmpItemKindCopilot",      { fg = "#94e2d5", bold = true })
vim.api.nvim_set_hl(0, "CmpItemKindSupermaven",   { fg = "#a6e3a1", bold = true })
vim.api.nvim_set_hl(0, "CmpItemKindFunction",     { fg = "#7aa2f7" })
vim.api.nvim_set_hl(0, "CmpItemKindMethod",       { fg = "#7aa2f7" })
vim.api.nvim_set_hl(0, "CmpItemKindVariable",     { fg = "#c0caf5" })
vim.api.nvim_set_hl(0, "CmpItemKindConstant",     { fg = "#ff9e64" })
vim.api.nvim_set_hl(0, "CmpItemKindClass",        { fg = "#e0af68" })
vim.api.nvim_set_hl(0, "CmpItemKindInterface",    { fg = "#bb9af7" })
vim.api.nvim_set_hl(0, "CmpItemKindProperty",     { fg = "#9ece6a" })
vim.api.nvim_set_hl(0, "CmpItemKindField",        { fg = "#9ece6a" })
vim.api.nvim_set_hl(0, "CmpItemKindEnum",         { fg = "#f7768e" })
vim.api.nvim_set_hl(0, "CmpItemKindEnumMember",   { fg = "#f7768e" })
vim.api.nvim_set_hl(0, "CmpItemKindKeyword",      { fg = "#bb9af7" })
vim.api.nvim_set_hl(0, "CmpItemKindSnippet",      { fg = "#565f89" })
vim.api.nvim_set_hl(0, "CmpItemKindText",         { fg = "#a9b1d6" })
vim.api.nvim_set_hl(0, "CmpItemKindModule",       { fg = "#9ece6a" })
vim.api.nvim_set_hl(0, "CmpItemKindStruct",       { fg = "#ff9e64" })
vim.api.nvim_set_hl(0, "CmpItemKindConstructor",  { fg = "#7aa2f7" })
vim.api.nvim_set_hl(0, "CmpItemKindTypeParameter",{ fg = "#7dcfff" })
vim.api.nvim_set_hl(0, "CmpItemKindOperator",     { fg = "#f7768e" })
vim.api.nvim_set_hl(0, "CmpItemKindEvent",        { fg = "#e0af68" })

vim.cmd [[
  highlight NeoTreeFloatBorder guifg=#7AA2F7
  highlight NeoTreeFloatTitle guifg=#ffb86c
]]

vim.api.nvim_set_hl(0, "DevIconVscode", { fg = "#007ACC" })
vim.api.nvim_set_hl(0, "DevIconGithub", { fg = "#7AA2F7" })
