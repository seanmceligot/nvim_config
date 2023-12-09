vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

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


local which_key_plugin = {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 100
    end,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    }
}

local mason_plugin = {
    "williamboman/mason.nvim"
}

local plugins = { mason_plugin, which_key_plugin }

require("lazy").setup(plugins)

require("mason").setup()

local wk = require("which-key")
local wk_mappings = {
  v = { ":visual<CR>", "Enter Visual Mode" },
  d = { ":delete<CR>", "Delete" },
  c = { ":change<CR>", "Change" },
  -- Add more mappings as needed
}
wk.register(wk_mappings, { prefix = "<leader>" })
