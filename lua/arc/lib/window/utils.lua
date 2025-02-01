local M = {}

--- @param config vim.api.keyset.win_config?
--- @return vim.api.keyset.win_config
M.default = function(config)
	if config == nil then
		config = {}
	end

	local default_config = {
		relative = "editor",
		width = M.width("70%"),
		height = M.height("75%"),
		style = "minimal",
		border = "rounded",
	}
	for key, val in pairs(default_config) do
		if config[key] == nil then
			config[key] = val
		end
	end
	return config
end

--- @param width string
M.width = function(width)
	return math.floor(vim.o.columns * (tonumber(string.sub(width, 1, #width - 1)) / 100))
end

--- @param height string
M.height = function(height)
	return math.floor(vim.o.lines * (tonumber(string.sub(height, 1, #height - 1)) / 100))
end

--- @param config vim.api.keyset.win_config
--- @return vim.api.keyset.win_config
M.center = function(config)
	config.col = math.floor((vim.o.columns - config.width) / 2)
	config.row = math.floor((vim.o.lines - config.height) / 2 - 1)

	return config
end

return M
