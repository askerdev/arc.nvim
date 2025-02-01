# Arcanum plugin for Neovim

## Installation with `lazy`

```lua
return {
  "askerdev/arc.nvim",
  keys = function()
    local arc = require("arc.builtin")
    return {
      { "<leader><leader>", mode = "n", arc.ls_files, desc = "Find arc files" },
    }
  end,
}
```
