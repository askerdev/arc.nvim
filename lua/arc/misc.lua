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

return M
