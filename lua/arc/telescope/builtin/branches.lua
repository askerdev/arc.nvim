local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local config = require("telescope.config").values
local utils = require("arc.utils")

return utils.picker(function(opts)
	pickers
		.new(opts, {
			prompt_title = "Arc Branches",

			finder = finders.new_dynamic({
				fn = function()
					return utils.job({ "branch", "-l" })
				end,
				entry_maker = function(entry)
					local value = vim.trim(entry)

					if value[1] == "*" then
						value = value:sub(2, #value)
					end

					return {
						value = value,
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
					utils.run({ "checkout", selection.value })
				end)
				return true
			end,
		})
		:find()
end)
