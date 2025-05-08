local M = {}

---@class HunkDiffEntry
---@field start number
---@field count number

---@class HunkHeader
---@field prev HunkDiffEntry
---@field now HunkDiffEntry

---@param line string
---@return HunkHeader
function M._parse_hunk_header(line)
	local a_start, a_count, b_start, b_count = line:match("^@@%s+-([%d]+),?([%d]*)%s+%+([%d]+),?([%d]*)%s+@@.*")
	a_count = a_count ~= "" and tonumber(a_count) or 1
	b_count = b_count ~= "" and tonumber(b_count) or 1
	a_start, b_start = tonumber(a_start), tonumber(b_start)
	if a_start == nil then
		a_count = nil
	end
	if b_start == nil then
		b_count = nil
	end
	return {
		prev = {
			start = a_start,
			count = a_count,
		},
		now = {
			start = b_start,
			count = b_count,
		},
	}
end

---@class arc.Hunk
---@field lstart number Start line number
---@field lend number End line number
---@field type "a" | "m" | "d" Type of hunk
---@field raw string[] Raw arc diff
---@field lprev string[] Deleted lines
---@field lnow string[] Added lines

---Parses git format diff and returns table with
---lines as key and status as value
---@param input string
function M.parse_hunks(input)
	input = vim.trim(input)
	---@type arc.Hunk[]
	local diff = {}

	if #input == 0 then
		return diff
	end

	local current_hunk = nil
	local current_raw_hunk = {}

	for _, line in ipairs(vim.split(input, "\n")) do
		line = vim.trim(line)
		--- Hunk header
		if #line >= 2 and string.sub(line, 1, 2) == "@@" then
			if current_hunk ~= nil then
				current_hunk.raw = current_raw_hunk
				table.insert(diff, current_hunk)
				current_hunk = nil
				current_raw_hunk = {}
			end

			local header = M._parse_hunk_header(line)
			--- Only add lines
			if header.prev.count == 0 and header.now.count ~= 0 then
				current_hunk = {
					type = "a",
					lstart = header.now.start,
					lend = header.now.start + header.now.count - 1,
				}
			--- Only remove lines
			elseif header.now.count == 0 and header.prev.count ~= 0 then
				current_hunk = {
					type = "d",
					lstart = header.now.start,
					lend = header.now.start,
				}
			--- Both added and removed lines
			else
				current_hunk = {
					type = "m",
					lstart = header.now.start,
					lend = header.now.start + header.now.count - 1,
				}
			end
		elseif #line >= 3 and (vim.startswith(line, "+++") or vim.startswith(line, "---")) then
		elseif #line >= 1 and (vim.startswith(line, "-") or vim.startswith(line, "+")) then
			table.insert(current_raw_hunk, line)
		end
	end
	if current_hunk ~= nil then
		current_hunk.raw = current_raw_hunk
		table.insert(diff, current_hunk)
		current_hunk = nil
		current_raw_hunk = {}
	end

	for _, hunk in ipairs(diff) do
		local lprev = {}
		local lnow = {}

		for _, line in ipairs(hunk.raw) do
			if vim.startswith(line, "-") then
				table.insert(lprev, line:sub(2))
			elseif vim.startswith(line, "+") then
				table.insert(lnow, line:sub(2))
			end
		end

		hunk.lprev = lprev
		hunk.lnow = lnow
	end

	return diff
end

return M
