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

-- mason :Mason
local mason_plugin = {
    "williamboman/mason.nvim"
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
local plugins = { mason_plugin, which_key_plugin, diffview_plugin, treesitter_plugin }

-- lazy
require("lazy").setup(plugins)
-- mason
require("mason").setup()
-- which key
local wk = require("which-key")
local wk_mappings = {
   d = { "<cmd>DiffviewOpen<cr>", "DiffView" }, 
   w = { "<cmd>WhichKey<cr>", "WhichKey" }, 
   m = { "<cmd>Mason<cr>", "Mason" }, 
}
wk.register(wk_mappings, { prefix = "<leader>" })
