local M = {}

M.config = {}

setmetatable(M, {
	__index = function(t, k)
		local picker = "arc.picker."
		t.config.sources = t.config.sources or require(picker .. "sources")
		t.config.finders = t.config.finders or require(picker .. "finders")
		t.config.actions = t.config.actions or require(picker .. "actions")
		t.config.preview = t.config.preview or require(picker .. "preview")
		t.config.format = t.config.format or require(picker .. "format")
		for key, source in pairs(t.config.sources) do
			if key == k then
				source.finder = t.config.finders[source.finder] or source.finder
				source.confirm = t.config.actions[source.confirm] or source.confirm
				source.preview = t.config.preview[source.preview] or source.preview
				source.format = t.config.format[source.format] or source.format
				t[k] = function()
					Snacks.picker.pick(source)
				end
			end
		end
		return rawget(t, k)
	end,
})

return M
