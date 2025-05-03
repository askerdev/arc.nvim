local M = {}

---@param cmd string[]
---@param ctx snacks.picker.preview.ctx
---@param opts? {add?:fun(text:string, row:number), env?:table<string, string>, pty?:boolean, ft?:string}
function M.preview_cmd(cmd, ctx, opts)
	opts = opts or {}
	local buf = ctx.preview:scratch()
	vim.bo[buf].buftype = "nofile"
	local pty = opts.pty ~= false and not opts.ft
	local killed = false
	local chan = pty and vim.api.nvim_open_term(buf, {}) or nil
	local output = {} ---@type string[]
	local line ---@type string?
	local l = 0

	---@param text string
	local function add_line(text)
		l = l + 1
		vim.bo[buf].modifiable = true
		if opts.add then
			opts.add(text, l)
		else
			vim.api.nvim_buf_set_lines(buf, l - 1, l, false, { text })
		end
		vim.bo[buf].modifiable = false
	end

	---@param data string
	local function add(data)
		output[#output + 1] = data
		if chan then
			if pcall(vim.api.nvim_chan_send, chan, data) then
				vim.api.nvim_buf_call(buf, function()
					vim.cmd("norm! gg")
				end)
			end
		else
			line = (line or "") .. data
			local lines = vim.split(line, "\r?\n")
			line = table.remove(lines)
			for _, text in ipairs(lines) do
				add_line(text)
			end
		end
	end

	local jid = vim.fn.jobstart(cmd, {
		height = pty and vim.api.nvim_win_get_height(ctx.win) or nil,
		width = pty and vim.api.nvim_win_get_width(ctx.win) or nil,
		pty = pty,
		cwd = ctx.item.cwd or ctx.picker.opts.cwd,
		env = vim.tbl_extend("force", {
			PAGER = "cat",
			DELTA_PAGER = "cat",
		}, opts.env or {}),
		on_stdout = function(_, data)
			if not vim.api.nvim_buf_is_valid(buf) then
				return
			end
			add(table.concat(data, "\n"))
		end,
		on_exit = function(_, code)
			if not killed and line and line ~= "" and vim.api.nvim_buf_is_valid(buf) then
				add_line(line)
			end
			if not killed and code ~= 0 then
				Snacks.notify.error(
					("Terminal **cmd** `%s` failed with code `%d`:\n- `vim.o.shell = %q`\n\nOutput:\n%s"):format(
						type(cmd) == "table" and table.concat(cmd, " ") or cmd,
						code,
						vim.o.shell,
						vim.trim(table.concat(output, ""))
					)
				)
			end
		end,
	})
	if opts.ft then
		ctx.preview:highlight({ ft = opts.ft })
	end
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = buf,
		callback = function()
			killed = true
			vim.fn.jobstop(jid)
			if chan then
				vim.fn.chanclose(chan)
			end
		end,
	})
	if jid <= 0 then
		Snacks.notify.error(("Failed to start terminal **cmd** `%s`"):format(cmd))
	end
end

return M
