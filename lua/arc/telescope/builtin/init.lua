local M = {}

local builtin = { "ls_files", "branches", "pr_list" }

for _, v in ipairs(builtin) do
	M[v] = require("arc.telescope.builtin." .. v)
end

return M
