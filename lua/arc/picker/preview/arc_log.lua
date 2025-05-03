local misc = require("arc.picker.misc")
local ns = vim.api.nvim_create_namespace("snacks.picker.preview")

---@param ctx snacks.picker.preview.ctx
return function(ctx)
	local cmd = {
		"arc",
		"log",
		"--format={commit} {title} ({date_rfc})",
		"--color=never",
		"-n34",
		ctx.item.branch,
	}
	local row = 0
	misc.preview_cmd(cmd, ctx, {
		ft = "git",
		---@param text string
		add = function(text)
			local commit, msg, date = text:match("^(%S+) (.*) %((.*)%)$")
			if commit then
				row = row + 1
				local hl = Snacks.picker.format.git_log({
					idx = 1,
					score = 0,
					text = "",
					commit = commit,
					msg = msg,
					date = date,
				}, ctx.picker)
				Snacks.picker.highlight.set(ctx.buf, ns, row, hl)
			end
		end,
	})
end
