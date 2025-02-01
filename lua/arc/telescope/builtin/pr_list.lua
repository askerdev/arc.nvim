local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local config = require("telescope.config").values
local utils = require("arc.utils")

return utils.picker(function(opts)
	pickers
		.new(opts, {
			prompt_title = "Arc PRs",

			finder = finders.new_dynamic({
				fn = function()
					return utils.job({ "pr", "list" })
				end,
				entry_maker = function(entry)
					if entry:sub(1, 2) == "Id" then
						return {}
					end

					return {
						value = entry:sub(1, 7),
						display = entry,
						ordinal = entry,
					}
				end,
			}),

			sorter = config.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					utils.run({ "pr", "view", selection.value })
				end)
				return true
			end,
		})
		:find()
end)
