local M = {}

-- Enable/disable languages
local enabled = {
  go = true,
  lua = true,
  nix = true,
  web = true,
  docker = true,
  yaml = true
}

local langs = {}

-- Path to language configs
local lang_path = vim.fn.stdpath("config") .. "/lua/lang/"

local handle = vim.loop.fs_scandir(lang_path)
if handle then
  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then break end
    if type == "file" and name:match("%.lua$") then
      local lang_name = name:gsub("%.lua$", "")
      if enabled[lang_name] then
        local ok, conf = pcall(require, "lang." .. lang_name)
        if ok and conf then
          table.insert(langs, conf)
        end
      end
    end
  end
end

M.langs = langs
return M
