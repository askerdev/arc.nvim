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
