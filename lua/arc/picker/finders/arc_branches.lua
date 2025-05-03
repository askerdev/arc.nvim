local uv = vim.uv or vim.loop

local commit_pat = ("[a-z0-9]"):rep(7)

---@param opts snacks.picker.Config
---@type snacks.picker.finder
return function(opts, ctx)
	local args = { "branch", "-vvl" }
	local cwd = vim.fs.normalize(opts and opts.cwd or uv.cwd() or ".") or nil

	local patterns = {
    -- stylua: ignore start
    --- e.g. "* (HEAD detached at f65a2c8) f65a2c8 chore(build): auto-generate docs"
    "^(.)%s(%b())%s+(" .. commit_pat .. ")%s*(.*)$",
    --- e.g. "  main                       d2b2b7b [origin/main: behind 276] chore(build): auto-generate docs"
    "^(.)%s(%S+)%s+(".. commit_pat .. ")%s*(.*)$",
		-- stylua: ignore end
	} ---@type string[]

	return require("snacks.picker.source.proc").proc({
		opts,
		{
			cwd = cwd,
			cmd = "arc",
			args = args,
			---@param item snacks.picker.finder.Item
			transform = function(item)
				item.cwd = cwd
				for p, pattern in ipairs(patterns) do
					local status, branch, commit, msg = item.text:match(pattern)
					if status then
						local detached = p == 1
						item.current = status == "*"
						item.branch = not detached and branch or nil
						item.commit = commit
						item.msg = msg
						item.detached = detached
						return
					end
				end
				Snacks.notify.warn("failed to parse branch: " .. item.text)
				return false -- skip items we could not parse
			end,
		},
	}, ctx)
end
