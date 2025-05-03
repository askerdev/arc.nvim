return function(item)
	local a = Snacks.picker.util.align
	local ret = {} ---@type snacks.picker.Highlight[]
	ret[#ret + 1] = { a(item.summary, 55, { truncate = true }), "SnacksPickerGitBranch" }
	ret[#ret + 1] = { " " }
	return ret
end
