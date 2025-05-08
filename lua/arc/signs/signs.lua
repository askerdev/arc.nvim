---@module 'snacks'

local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local coro = require("arc.coro")
local misc = require("arc.misc")
local diff = require("arc.diff")

local M = {}

---@type arc.Hunk[]
M.hunks = {}

M.signs = {}

---@return arc.Hunk | nil
function M.find_hunk_under_cursor()
	local current_win_id = vim.api.nvim_get_current_win()
	local cursor = vim.api.nvim_win_get_cursor(current_win_id)
	local line = cursor[1]

	for _, hunk in ipairs(M.hunks) do
		if hunk.lstart <= line and line <= hunk.lend then
			return hunk
		end
	end

	return nil
end

function M.arc_root()
	local ok, root = pcall(vim.fn.system, "arc root")

	if not ok or vim.startswith(vim.trim(root), "Not a mounted arc repository.") then
		return nil
	end

	return vim.trim(root)
end

---@param bufnr number
---@param type "a" | "m" |"d"
---@param lstart number
---@param lend number
function M.place_sign(bufnr, type, lstart, lend)
	local sign_name = {
		["a"] = "ArcSign_A",
		["m"] = "ArcSign_M",
		["d"] = "ArcSign_D",
	}

	if lstart == 0 or lend == 0 then
		local id = vim.fn.sign_place(0, "arc_diff", "ArcSign_TopD", bufnr, { lnum = 1, priority = 10 })
		table.insert(M.signs, id)
		return
	end

	for lnum = lstart, lend do
		local id = vim.fn.sign_place(0, "arc_diff", sign_name[type], bufnr, { lnum = lnum, priority = 10 })
		table.insert(M.signs, id)
	end
end

---@param bufnr number
---@param id number
function M.unplace_sign(bufnr, id)
	vim.fn.sign_unplace("arc_diff", { buffer = bufnr, id = id })
end

function M.co_fetch_hunks()
	local out = misc.co_system({ "arc", "diff", "-U0", "HEAD", vim.fn.expand("%") }, { text = true })
	M.hunks = diff.parse_hunks(out.stdout)
end

---@param callback fun(hunk: arc.Hunk)
function M.each_hunk(callback)
	for _, hunk in ipairs(M.hunks) do
		callback(hunk)
	end
end

---@param buf number
function M.update_signs(buf)
	M.clean(buf)
	M.each_hunk(function(hunk)
		M.place_sign(buf, hunk.type, hunk.lstart, hunk.lend)
	end)
end

---@param bufnr number
function M.clean(bufnr)
	for _, sign in ipairs(M.signs) do
		M.unplace_sign(bufnr, sign)
	end
end

function M.setup()
	local arc_root = M.arc_root()

	if arc_root == nil then
		return
	end

	vim.api.nvim_set_hl(0, "ArcSignDelete", { fg = "#ff2222", bold = true })
	vim.api.nvim_set_hl(0, "ArcSignAdd", { fg = "#449944", bold = true })
	vim.api.nvim_set_hl(0, "ArcSignChange", { fg = "#bbbb00", bold = true })
	vim.fn.sign_define("ArcSign_A", { text = "┃", texthl = "ArcSignAdd" })
	vim.fn.sign_define("ArcSign_M", { text = "┃", texthl = "ArcSignChange" })
	vim.fn.sign_define("ArcSign_D", { text = "_", texthl = "ArcSignDelete" })
	vim.fn.sign_define("ArcSign_TopD", { text = "‾", texthl = "ArcSignDelete" })
	vim.fn.sign_define("ArcLine_A", { text = "", linehl = "DiffAdd" })
	vim.fn.sign_define("ArcLine_D", { text = "", linehl = "DiffDelete" })

	local group = vim.api.nvim_create_augroup("ArcSign_Group", { clear = true })

	vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
		group = group,
		callback = function(args)
			local full_path = vim.api.nvim_buf_get_name(args.buf)
			if not vim.startswith(full_path, arc_root) then
				return
			end

			coro.go(function()
				M.co_fetch_hunks()
				M.update_signs(args.buf)
			end)

			local async_update_id = vim.api.nvim_create_autocmd({
				"BufWritePost",
			}, {
				group = group,
				buffer = args.buf,
				callback = coro.wrap(function()
					M.co_fetch_hunks()
					M.update_signs(args.buf)
				end),
			})

			local update_id = vim.api.nvim_create_autocmd({
				"BufReadPost",
				"TextChanged",
				"InsertLeave",
				"InsertEnter",
			}, {
				group = group,
				buffer = args.buf,
				callback = function()
					M.update_signs(args.buf)
				end,
			})

			vim.api.nvim_create_autocmd({ "BufDelete" }, {
				buffer = args.buf,
				once = true,
				group = group,
				callback = function()
					vim.api.nvim_del_autocmd(async_update_id)
					vim.api.nvim_del_autocmd(update_id)
					M.clean(args.buf)
				end,
			})
		end,
	})
end

function M.hunk_preview()
	local hunk = M.find_hunk_under_cursor()

	if hunk == nil then
		return
	end

	local popup = Popup({
		enter = false,
		focusable = false,
		border = {
			style = "rounded",
		},
		win_options = {
			wrap = true,
		},
	})

	popup:update_layout({
		relative = "cursor",
		position = {
			row = 1,
			col = 1,
		},
		size = {
			width = "100%",
			height = math.min(#hunk.raw, 5),
		},
	})

	popup:map("n", "q", function()
		popup:unmount()
	end)

	popup:mount()

	popup:on(event.BufLeave, function()
		popup:unmount()
	end)

	vim.api.nvim_buf_set_lines(
		popup.bufnr,
		0,
		1,
		false,
		misc.map(hunk.raw, function(x)
			return x:sub(2)
		end)
	)

	local signs = {}
	for i, hunk_line in ipairs(hunk.raw) do
		local type = "ArcLine_D"
		if vim.startswith(hunk_line, "+") then
			type = "ArcLine_A"
		end
		local sign_id = vim.fn.sign_place(0, "arc_diff", type, popup.bufnr, { lnum = i, priority = 10 })
		table.insert(signs, sign_id)
	end

	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		buffer = 0,
		once = true,
		callback = function()
			for _, sign_id in ipairs(signs) do
				vim.fn.sign_unplace("arc_diff", { buffer = popup.bufnr, id = sign_id })
			end
			popup:unmount()
		end,
	})
end

function M.hunk_reset()
	local hunk = M.find_hunk_under_cursor()

	if hunk == nil then
		return
	end

	vim.api.nvim_buf_set_lines(0, hunk.lstart - 1, hunk.lend, false, hunk.lprev)
	vim.api.nvim_cmd({ cmd = "w" }, {})
end

return M
