local builtin = require("arc.telescope.builtin")

return require("telescope").register_extension({
	exports = builtin,
})
