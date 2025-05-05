local diff = require("arc.diff")

local M = {}

M.signs = {}

function M.is_arc_repo()
	local ok, root = pcall(vim.fn.system, "arc root")

	return ok and not vim.startswith(vim.trim(root), "Not a mounted arc repository.")
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

---@param bufnr number
function M.place(bufnr)
	local diff_output = vim.trim(vim.fn.system("arc diff -U0 HEAD " .. vim.fn.expand("%")))
	local hunks = diff.parse_hunks(diff_output)

	for _, hunk in ipairs(hunks) do
		vim.schedule(function()
			M.place_sign(bufnr, hunk.type, hunk.lstart, hunk.lend)
		end)
	end
end

---@param bufnr number
function M.clean(bufnr)
	for _, sign in ipairs(M.signs) do
		M.unplace_sign(bufnr, sign)
	end
end

function M.setup()
	if not M.is_arc_repo() then
		return
	end

	vim.api.nvim_set_hl(0, "ArcSignDelete", { fg = "#ff2222", bold = true })
	vim.api.nvim_set_hl(0, "ArcSignAdd", { fg = "#449944", bold = true })
	vim.api.nvim_set_hl(0, "ArcSignChange", { fg = "#bbbb00", bold = true })
	vim.fn.sign_define("ArcSign_A", { text = "", numhl = "DiffAdd" })
	vim.fn.sign_define("ArcSign_M", { text = "", numhl = "DiffChange" })
	vim.fn.sign_define("ArcSign_D", { text = "_", texthl = "ArcSignDelete" })

	local group = vim.api.nvim_create_augroup("ArcSign_Group", { clear = true })

	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		once = true,
		group = group,
		callback = function(args)
			M.place(args.buf)
		end,
	})

	local update_id = vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "InsertEnter" }, {
		group = group,
		callback = function(args)
			M.clean(args.buf)
			M.place(args.buf)
		end,
	})

	vim.api.nvim_create_autocmd({ "BufDelete" }, {
		once = true,
		group = group,
		callback = function(args)
			vim.api.nvim_del_autocmd(update_id)
			M.clean(args.buf)
		end,
	})
end

return M
