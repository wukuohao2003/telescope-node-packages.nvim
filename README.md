# Telescope Node Packages

## Introduction

> telescope-node-packages.nvim is Neovim plugin integrated with [Telescope](https://github.com/nvim-telescope/telescope.nvim),
> designed to manage packages in Node.js projects. It enables developers to
> conveniently browse , search, and manage project dependencies.

## Demonstrate

![Demonstrate](./telescope-node-packages.gif)

## Installation

- Using Packer

If you use Packer as your plugin manager, add the following code to your init.lua or plugins.lua file:

```lua
use {
    'wukuohao2003/telescope-node-packages.nvim',
    requires = { 'nvim-telescope/telescope.nvim' }
}
```

- Using vim-plug

```lua
Plug 'wukuohao2003/telescope-node-packages.nvim'
Plug 'nvim-telescope/telescope.nvim'
```

- Using SuperInstaller

```lua
packages = {
    "wukuohao2003/telescope-node-packages.nvim"
    "nvim-telescope/telescope.nvim"
}
```

## Load extension

```lua
require('telescope').setup {
    extensions = {
        node_packages = {}
    }
}

require('telescope').load_extension('node_packages')
```

## Usage

### Opening the Telescope Node Packages Menu

In Neovim, you can use the following command to open the Telescope Node Packages menu:

```vim
:Telescope node_packages
```

Or use the following code in Lua:

```lua
require('telescope').extensions.node_packages.start()
```

## Configuration

### Adding Configuration to package.json

In your project's package.json file, you need to add the following configuration to specify the package manager:

```json
{
  "node_packages": {
    "command": "yarn | npm | pnpm"
  }
}
```

## Browsing and Searching for packages

After opening the menu, you can use the default Telescope shortcuts to browse and search for packages. For example:

- Install packages using carriage return in insert mode, with multiple package names separated by commas
- Select and uninstall packages in normal mode
