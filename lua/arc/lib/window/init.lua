local utils = require("arc.lib.window.utils")

Window = {}
--- @param get_config function
--- @param enter boolean
function Window:new(get_config, enter)
	local this = {}
	this.buf = vim.api.nvim_create_buf(false, true)
	this.win = vim.api.nvim_open_win(this.buf, enter, get_config())

	function this:get_buffer()
		return self.buf
	end

	function this:get_window()
		return self.win
	end

	function this:close()
		vim.api.nvim_win_close(self.win, true)
		vim.api.nvim_buf_delete(self.buf, {
			force = true,
		})
	end

	function this:resize()
		if self.win == nil or not vim.api.nvim_win_is_valid(self.win) then
			return
		end
		local status, exception = pcall(function()
			vim.api.nvim_win_set_config(self.win, get_config())
		end)
		if not status then
			vim.notify(vim.inspect(exception))
		end
	end

	vim.api.nvim_create_autocmd("VimResized", {
		group = vim.api.nvim_create_augroup("arc-vim-resized", {}),
		buffer = this.buf,
		callback = function()
			this:resize()
		end,
	})

	vim.keymap.set("n", "<ESC>", function()
		this:close()
	end, { buffer = this.buf })

	setmetatable(this, self)
	self.__index = self
	return this
end

return utils
