vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

-- lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- mason :Mason
local mason_plugin = {
    "williamboman/mason.nvim",
    'williamboman/mason-lspconfig.nvim'
}

-- lsp  :LspInfo
-- neodev for editing .config/nvim/init.lua
local lspconfig_plugin  = {
	"neovim/nvim-lspconfig",
	"folke/neodev.nvim",
}

-- which key :WhichKey
local which_key_plugin = {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 100
    end,
    opts = { }
}

-- diffview :DiffViewOpen
local diffview_plugin = {
    'sindrets/diffview.nvim'
}

-- TreeSitter :TSInstall
local treesitter_plugin = {
'nvim-treesitter/nvim-treesitter'
, 'nvim-treesitter/nvim-treesitter-textobjects'
}

-- lazy
local plugins = { mason_plugin, which_key_plugin, diffview_plugin, treesitter_plugin, lspconfig_plugin }
require("lazy").setup(plugins)

-- mason and lsp
require("neodev").setup()
require("mason").setup()
require("mason-lspconfig").setup()
local lspconfig = require('lspconfig')

-- :h mason-lspconfig-automatic-server-setup
require("mason-lspconfig").setup_handlers {
function (server_name) -- default handler (optional)
    lspconfig[server_name].setup {}
end,
}

-- which key
local wk = require("which-key")
local wk_mappings = {
   d = { "<cmd>DiffviewOpen<cr>", "DiffView" },
   w = { "<cmd>WhichKey<cr>", "WhichKey" },
   m = { "<cmd>Mason<cr>", "Mason" },
}
wk.register(wk_mappings, { prefix = "<leader>" })

--- LSP Keybindings ---

-- Open the diagnostics floating window.
-- Space e: Show diagnostics in a floating window.
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)

-- Go to the previous diagnostic error.
-- [d: Jump to the previous error or warning.
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)

-- Go to the next diagnostic error.
-- ]d: Jump to the next error or warning.
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

-- Open the diagnostics location list.
-- Space q: Open the location list for diagnostics.
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
group = vim.api.nvim_create_augroup('UserLspConfig', {}),
callback = function(ev)
-- Enable completion triggered by <c-x><c-o>
vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
-- Buffer local mappings.
-- See `:help vim.lsp.*` for documentation on any of the below functions
local opts = { buffer = ev.buf }

-- gD: Jump to the declaration of the symbol under the cursor.
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)

-- gd: Jump to the definition of the symbol under the cursor.
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

-- K: Show hover information for the symbol under the cursor.
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

-- gi: Jump to the implementation of the symbol under the cursor.
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)

-- <C-k>: Show signature help for the symbol under the cursor.
vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

-- Space wa: Add the current buffer's directory as a
vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
vim.keymap.set('n', '<space>wl', function()
print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, opts)
vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
vim.keymap.set('n', '<space>f', function()
vim.lsp.buf.format { async = true }
end, opts)
end,
})

