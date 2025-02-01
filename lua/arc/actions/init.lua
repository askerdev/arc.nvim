local utils = require("arc.utils")

local M = {}

--- @param branch string
M.checkout = function(branch)
	return utils.run({ "checkout", branch })
end

M.pr = {
	--- @param id string
	view = function(id)
		return utils.run({ "pr", "view", id })
	end,
}

M.commit = function()
	vim.cmd.edit("term://arc commit")
end

return M
