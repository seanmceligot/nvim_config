
# My NeoVim configuration. 

- simple and from scratch readable config
- Use which-key instead of memorizing keybindinds

## Features

- Lazy.nvim for efficient plugin management
- Mason for package management
- LSP integration for a variety of languages
- WhichKey for fast and efficient key mappings
- DiffView for convenient diffing
- Treesitter for improved syntax highlighting and code navigation

## Installation
```shell
mv ~/.config/nvm ~/.config/nvim.old
git clone https://github.com/seanmceligot/nvim_config.git ~/.config/nvim
```

### LSP keybindings

- View
    - <leader>lvd: Open diagnostics
    - <leader>lvp: Previous diagnostics error
    - <leader>lvn: Next diagnostics error
    - <leader>lvl: Diagnostics location list
    - <leader>lvh: Hover information
    - <leader>lvs: Signature help
    - <leader>lvt: Type definition

- Goto
    - <leader>lgr: Find references
    - <leader>lgd: Jump to declaration
    - <leader>lga: Jump to definition (assignment)
    - <leader>lgi: Jump to implementation

- Workspce
    - <leader>lwa: Add workspace folder
    - <leader>lwr: Remove workspace folder
    - <leader>lfl: List workspace folders

- Edit
    - <leader>ler: Edit rename symbol
    - <leader>lea: Edit code action
    - <leader>lef: Edit format buffer

### Resources

- Lazy.nvim: https://github.com/folke/lazy.nvim
- Mason: https://github.com/williamboman/mason-lspconfig.nvim
- LSPconfig: https://github.com/neovim/nvim-lspconfig
- WhichKey: https://github.com/folke/which-key.nvim
- DiffView: https://github.com/sindrets/diffview.nvim
- Treesitter: https://github.com/nvim-treesitter

