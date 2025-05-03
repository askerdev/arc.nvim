local uv = vim.uv or vim.loop

---@param opts snacks.picker.git.files.Config
---@type snacks.picker.finder
return function(opts, ctx)
	local args = { "pr", "list" }
	if not opts.cwd then
		opts.cwd = uv.cwd() or "."
		ctx.picker:set_cwd(opts.cwd)
	end
	local cwd = vim.fs.normalize(opts.cwd) or nil
	return require("snacks.picker.source.proc").proc({
		opts,
		{
			cmd = "arc",
			args = args,
			---@param item snacks.picker.finder.Item
			transform = function(item)
				item.cwd = cwd
				item.id, item.summary = item.text:match("(%S+)%s+%S+%s+%S+%s+(.+)")
				if item.id == "Id" then
					return false
				end
			end,
		},
	}, ctx)
end
