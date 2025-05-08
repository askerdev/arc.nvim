local coro = require("arc.coro")
local M = {}

function M.lazy_module(path)
	local LazyModule = {}

	setmetatable(LazyModule, {
		__index = function(t, k)
			if k == nil then
				return nil
			end
			if rawget(t, k) then
				return rawget(t, k)
			end
			local ok, module = pcall(require, path .. "." .. k)
			if not ok then
				return nil
			end
			t[k] = module
			return rawget(t, k)
		end,
	})

	return LazyModule
end

---@param cmd string[]
---@param opts? vim.SystemOpts
---@return vim.SystemCompleted
function M.co_system(cmd, opts)
	return coro.create_task(function(callback)
		vim.system(cmd, opts or {}, function(result)
			if result.stdout then
				result.stdout = vim.trim(result.stdout)
			end
			callback(result)
		end)
	end)
end

function M.map(array, func)
	local new_array = {}
	for i, v in pairs(array) do
		new_array[i] = func(v)
	end
	return new_array
end

return M
