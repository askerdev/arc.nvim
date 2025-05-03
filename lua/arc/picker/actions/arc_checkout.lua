return function(picker, item)
	picker:close()
	if item then
		local what = item.branch or item.commit
		if not what then
			Snacks.notify.warn("No branch or commit found", { title = "Snacks Picker" })
			return
		end
		local cmd = { "arc", "checkout", what }
		if item.file then
			vim.list_extend(cmd, { "--", item.file })
		end
		Snacks.picker.util.cmd(cmd, function()
			Snacks.notify("Checkout " .. what, { title = "Snacks Picker" })
			vim.cmd.checktime()
		end, { cwd = item.cwd })
	end
end
