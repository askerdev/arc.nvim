---@module 'snacks'

local Arc = {}

setmetatable(Arc, {
	__index = function(t, k)
		---@diagnostic disable-next-line: no-unknown
		t[k] = require("arc." .. k)
		return rawget(t, k)
	end,
})

---@type arc.Plugins
_G.Arc = Arc

local M = {}

function M.setup() end

return M
