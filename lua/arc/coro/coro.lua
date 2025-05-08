local M = {}

---@alias Callback fun(result: any)
---@param task fun(callback: Callback)
function M.create_task(task)
	local co = coroutine.running()
	if not co then
		error("Must be called inside a coroutine")
	end

	task(function(result)
		vim.schedule(function()
			coroutine.resume(co, result)
		end)
	end)

	return coroutine.yield()
end

---@param task fun()
function M.wrap(task)
	return function()
		return M.go(task)
	end
end

---@param task fun()
function M.go(task)
	vim.schedule(function()
		local co = coroutine.create(task)
		coroutine.resume(co)
	end)
end

return M
