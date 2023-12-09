
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
    - Space lvd: Open diagnostics
    - Space lvp: Previous diagnostics error
    - Space lvn: Next diagnostics error
    - Space lvl: Diagnostics location list
    - Space lvh: Hover information
    - Space lvs: Signature help
    - Space lvt: Type definition

- Goto
    - Space lgr: Find references
    - Space lgd: Jump to declaration
    - Space lga: Jump to definition (assignment)
    - Space lgi: Jump to implementation

- Workspce
    - Space lwa: Add workspace folder
    - Space lwr: Remove workspace folder
    - Space lfl: List workspace folders

- Edit
    - Space ler: Edit rename symbol
    - Space lea: Edit code action
    - Space lef: Edit format buffer

### Resources

- Lazy.nvim: https://github.com/folke/lazy.nvim
- Mason: https://github.com/williamboman/mason-lspconfig.nvim
- LSPconfig: https://github.com/neovim/nvim-lspconfig
- WhichKey: https://github.com/folke/which-key.nvim
- DiffView: https://github.com/sindrets/diffview.nvim
- Treesitter: https://github.com/nvim-treesitter

