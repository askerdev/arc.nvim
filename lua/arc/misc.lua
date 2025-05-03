local M = {}

--- @param x table<any,any>
--- @return string[]
function M.flatten(x)
	local ret = {} --- @type string[]
	for k, v in pairs(x) do
		if type(k) == "number" then
			if type(v) == "table" then
				vim.list_extend(ret, M.flatten(v))
			elseif type(v) == "string" then
				ret[#ret + 1] = v
			end
		end
	end
	return ret
end

function M.parse_jsonl(jsonl_str)
	local results = {
		success = true,
		data = {},
		errors = {},
		stats = {
			total_lines = 0,
			parsed = 0,
			failed = 0,
		},
	}

	-- Split stream into lines using Neovim's built-in split
	local lines = vim.split(jsonl_str:gsub("\r\n?", "\n"), "\n")

	for i, line in ipairs(lines) do
		results.stats.total_lines = results.stats.total_lines + 1

		-- Skip empty lines
		if vim.trim(line) ~= "" then
			local ok, parsed = pcall(vim.json.decode, line)

			if ok then
				table.insert(results.data, parsed)
				results.stats.parsed = results.stats.parsed + 1
			else
				table.insert(results.errors, {
					line = i,
					content = line,
					error = parsed,
				})
				results.stats.failed = results.stats.failed + 1
				results.success = false
			end
		end
	end

	return results
end

return M
