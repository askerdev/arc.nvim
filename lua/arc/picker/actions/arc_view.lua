return function(picker, item)
	picker:close()
	if item then
		local what = item.id
		if not what then
			Snacks.notify.warn("No branch found", { title = "Snacks Picker" })
			return
		end
		local cmd = { "arc", "pr", "view", what }
		Snacks.picker.util.cmd(cmd, function()
			Snacks.notify("View pr " .. what, { title = "Snacks Picker" })
			vim.cmd.checktime()
		end, { cwd = item.cwd })
	end
end
