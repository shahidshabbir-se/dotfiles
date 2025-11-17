require "nvchad.mappings"

-- Load all keymap files inside lua/keymaps/
local path = vim.fn.stdpath "config" .. "/lua/keymaps"
local files = vim.fn.glob(path .. "/*.lua", false, true)

for _, file in ipairs(files) do
  local mod = file:match "keymaps/(.+)%.lua$"
  if mod then
    pcall(require, "keymaps." .. mod)
  end
end
