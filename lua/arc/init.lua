local M = {}

function M.setup() end

local arc = require("arc.vsc").new()
print(vim.inspect(arc:log()))

return M
