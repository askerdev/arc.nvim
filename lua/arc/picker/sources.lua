local M = {}

--- @type snacks.picker.Config
M.files = {
	title = "Files",
	finder = "arc_files",
}

--- @type snacks.picker.Config
M.branches = {
	title = "Branches",
	finder = "arc_branches",
	format = "git_branch",
	preview = "arc_log",
	confirm = "arc_checkout",
	on_show = function(picker)
		for i, item in ipairs(picker:items()) do
			if item.current then
				picker.list:view(i)
				Snacks.picker.actions.list_scroll_center(picker)
				break
			end
		end
	end,
}

--- @type snacks.picker.Config
M.pr_list = {
	title = "Pull Requests",
	finder = "arc_pr_list",
	format = "arc_pr",
	preview = "arc_log",
	confirm = "arc_view",
}

return M
