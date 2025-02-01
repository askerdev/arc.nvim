local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local config = require("telescope.config").values
local utils = require("arc.utils")

return utils.picker(function(opts)
	pickers
		.new(opts, {
			prompt_title = "Arc Files",

			finder = finders.new_dynamic({
				fn = function()
					return utils.job({ "ls-files" })
				end,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry,
						ordinal = entry,
					}
				end,
			}),

			sorter = config.generic_sorter(opts),
		})
		:find()
end)
