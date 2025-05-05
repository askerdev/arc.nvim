# Arcanum VSC plugin for Neovim

## Installation

_Recommended way_ with [Lazy](https://github.com/folke/lazy.nvim)

```lua
{
    "askerdev/arc.nvim",
    opts = {},
}
```

with [Packer](https://github.com/wbthomason/packer.nvim)

```lua
{
    "askerdev/arc.nvim",
    config = function()
        require("arc").setup({})
    end
}
```

## Example Snacks config

```lua
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@module 'arc'
	---@module 'snacks'
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = true },
		indent = { enabled = true },
		input = { enabled = true },
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		picker = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
	},
	-- stylua: ignore
	keys = {
		-- Top Pickers & Explorer
		{ "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
		{ "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
		{ "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
		-- arc
		{ "<leader>gb", function() Arc.picker.branches() end, desc = "Arc Branches" },
		{ "<leader>gp", function() Arc.picker.pr_list() end, desc = "Arc Pull Requests" },
		-- LSP
		{ "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
		{ "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
		{ "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
		{ "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
		{ "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
		{ "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
		{ "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
}
```
