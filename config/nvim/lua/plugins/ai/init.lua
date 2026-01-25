local enabled_plugins = {
	avante = false,
	copilot = true,
	codeium = false,
	supermaven = false,
}

local plugins = {}

for name, enabled in pairs(enabled_plugins) do
	if enabled then
		table.insert(plugins, require("plugins.ai." .. name))
	end
end

return plugins
