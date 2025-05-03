---@class arc.Arc
---@field _subcommands string[]
---@field _format "text" | "json" | "jsonl"
---@field _args any[]
---@field _options table
local Arc = {}
Arc.__index = Arc

function Arc.new()
	local self = setmetatable({}, Arc)
	self._args = {}
	self._options = {
		directory = ".",
		format = nil,
		verbose = false,
		output = nil,
	}
	self._format = "text"
	self._subcommands = {}
	return self
end

function Arc:json()
	self._format = "json"
	return self
end

function Arc:jsonl()
	self._format = "jsonl"
	return self
end

function Arc:cmd(cmd)
	table.insert(self._subcommands, cmd)
	return self
end

function Arc:arg(value)
	table.insert(self._args, value)
	return self
end

---@return unknown
function Arc:run()
	local cmd_parts = { "arc", unpack(self._subcommands) }

	if self._format == "json" or self._format == "jsonl" then
		table.insert(cmd_parts, "--json")
	end

	for _, arg in ipairs(self._args) do
		table.insert(cmd_parts, arg)
	end

	local result = vim.system(cmd_parts, { text = true }):wait()
	if result.code ~= 0 then
		error("Command failed with exit code: " .. result.stderr)
	end

	if self._format == "json" then
		local ok, parsed = pcall(vim.json.decode, vim.trim(result.stdout))
		if ok then
			return parsed
		else
			error("Failed to parse JSON output: " .. parsed)
		end
	elseif self._format == "jsonl" then
		local results = {}
		local json_lines = vim.split(vim.trim(result.stdout), "\n")
		for _, line in ipairs(json_lines) do
			local ok, parsed = pcall(vim.json.decode, vim.trim(line))
			if ok then
				table.insert(results, parsed)
			else
				error("Failed to parse JSON output: " .. parsed)
			end
		end
		return results
	elseif self._format == "text" then
		return vim.trim(result.stdout)
	end

	error("Failed to parse: unknown format")
end

---@param str string
function Arc:parse_list(str)
	return vim.split(str, "\n")
end

---Returns arc root absolute path
---@return string
function Arc:root()
	local arc = Arc.new()
	arc._options = vim.deepcopy(self._options)
	return arc:cmd("root"):run()
end

---@return string[]
function Arc:files()
	local arc = Arc.new()
	arc._options = vim.deepcopy(self._options)
	return arc:parse_list(arc:cmd("ls-files"):run())
end

---@class LogEntry
---@field commit string
---@field parents string[]
---@field author string
---@field date string
---@field revision string
---@field message string
---@field branches? {local: string[]; remote: string[]; head: boolean}

---@param max_count? number
---@return LogEntry[]
function Arc:log(max_count)
	max_count = max_count or 10
	local arc = Arc.new()
	arc._options = vim.deepcopy(self._options)
	return arc:cmd("log"):arg("--max-count=" .. max_count):json():run()
end

---@alias Branch {name: string, current: boolean}
---@return Branch[]
function Arc:branch()
	local arc = Arc.new()
	arc._options = vim.deepcopy(self._options)
	return arc:cmd("branch"):json():run()
end

---@class PR
---@field author string
---@field auto_merge string
---@field created_at {nanos: number;seconds: number}
---@field description string
---@field from_branch string
---@field from_id string
---@field id number
---@field issues string[]
---@field reviewers string[]
---@field status string
---@field summary string
---@field to_branch string
---@field url string

---@return PR[]
function Arc:pr_list()
	local arc = Arc.new()
	arc._options = vim.deepcopy(self._options)
	return arc:cmd("pr"):cmd("list"):jsonl():run()
end

return Arc
