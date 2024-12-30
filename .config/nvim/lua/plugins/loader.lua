local function load_plugins_recursively(directory)
  local plugin_specs = {}
  local all_files = vim.fn.globpath(directory, "**/*.lua", true, true)

  for _, file in ipairs(all_files) do
    if not file:find("loader.lua") and not file:find("icons.lua") then
      local relative_file = file:sub(#directory + 2) -- Strip base directory path
      local plugin_module = relative_file:gsub("%.lua$", ""):gsub("/", ".") -- Convert to module name

      local ok, spec = pcall(require, "plugins." .. plugin_module)
      if ok and type(spec) == "table" then
        table.insert(plugin_specs, spec)
      else
        vim.notify(
          "Error loading plugin: " .. plugin_module .. "\n\n" .. (spec or "Unknown error"),
          vim.log.levels.ERROR
        )
      end
    end
  end

  return plugin_specs
end

return load_plugins_recursively(vim.fn.stdpath("config") .. "/lua/plugins")
