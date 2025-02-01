local plenary = require("plenary")
local utils = require("telescope.utils")

local M = {}

--- @return boolean
M.is_git_repo = function()
	local stdout = utils.get_os_command_output({ "git", "rev-parse", "--is-inside-work-tree", "2>/dev/null" })
	return #stdout >= 1 and stdout[1] == "true"
end

--- @return boolean
M.is_arc_repo = function()
	local stdout = utils.get_os_command_output({ "arc", "rev-parse", "--is-inside-work-tree", "2>/dev/null" })
	return #stdout >= 1 and stdout[1] == "true"
end

--- @param fn function
M.picker = function(fn)
	return function(opts)
		if not M.is_arc_repo() then
			return
		end

		fn(opts)
	end
end

--- @param args string[]
M.job = function(args)
	local job_opts = {
		command = "arc",
		args = args,
	}
	local job = plenary.job:new(job_opts):sync()
	return job
end

--- @param args string[]
M.run = function(args)
	local cmd = { "arc" }
	vim.list_extend(cmd, args)
	return utils.get_os_command_output(cmd)
end

return M
