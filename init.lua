vim.g.mapleader = " "

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
local mason_plugin      = {
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
local which_key_plugin  = {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 100
	end,
	opts = {}
}

-- diffview :DiffViewOpen
local diffview_plugin   = {
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
	function(server_name) -- default handler (optional)
		lspconfig[server_name].setup {}
	end,
}

-- which key
local wk = require("which-key")
local wk_mappings = {
	d = { "<cmd>DiffviewOpen<cr>", "DiffView" },
	w = { "<cmd>WhichKey<cr>", "WhichKey" },
	m = { "<cmd>Mason<cr>", "Mason" },
	l = {
		name = "LSP",
		e = {
			name = "LSP -> Edit",
			r = "Rename",
			a = "Action",
			f = "Format File"
		},
		v = {
			name = "View",
			d = "Diagnostics",
			p = "Previous diagnostics",
			n = "Next diagnostics",
			l = "List",
			h = "Hover",
			s = "Signature",
			t = "Type"
		},
		g = {
			name = "Goto",
			r = "references",
			d = "Declaration",
			a = "Assignments",
			i = "implementation"
		},
		f = {
			name = "Folder",
			l = "list"
		},
	},
}
wk.register(wk_mappings, { prefix = "<leader>" })

-- View (lv)
--
-- Space lvd: Open diagnostics
vim.keymap.set('n', '<leader>lvd', vim.diagnostic.open_float)

-- Space lvp: Previous diagnostic error
vim.keymap.set('n', '<leader>lvp', vim.diagnostic.goto_prev)

-- Space lvn: Next diagnostic error
vim.keymap.set('n', '<leader>lvn', vim.diagnostic.goto_next)

-- Space lvl: Diagnostics location list
vim.keymap.set('n', '<leader>lvl', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		-- Enable completion with `<leader>lc`
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		-- Buffer local mappings
		local opts = { buffer = ev.buf }

		-- Go (Space lg)
		--
		-- Space lgr: Find references
		vim.keymap.set('n', '<leader>lgr', vim.lsp.buf.references, opts)

		-- Space lgd: Jump to declaration int i
		vim.keymap.set('n', '<leader>lgd', vim.lsp.buf.declaration, opts)

		-- Space lga: Jump to definition (assignement) var=val
		vim.keymap.set('n', '<leader>lga', vim.lsp.buf.definition, opts)

		-- Space lgi: Jump to implementation (gi)
		vim.keymap.set('n', '<leader>lgi', vim.lsp.buf.implementation, opts)


		-- View (Space lv)
		--
		-- Space lvh: Hover information
		vim.keymap.set('n', '<leader>lvh', vim.lsp.buf.hover, opts)

		-- Space lvs: Signature help
		vim.keymap.set('n', '<leader>lvs', vim.lsp.buf.signature_help, opts)

		-- Space lvt: Type definition
		vim.keymap.set('n', '<leader>lvt', vim.lsp.buf.type_definition, opts)

		-- Workspace (Space lw)
		--
		-- Add workspace folder
		vim.keymap.set('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder, opts)

		-- Remove workspace folder
		vim.keymap.set('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder, opts)

		-- List workspace folders
		vim.keymap.set('n', '<leader>lfl', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)

		-- Edit (Space le)
		-- Space ler: Edit Rename symbol
		vim.keymap.set('n', '<leader>ler', vim.lsp.buf.rename, opts)

		-- Space lea: Edit Code action
		vim.keymap.set({ 'n', 'v' }, '<leader>lea', vim.lsp.buf.code_action, opts)

		-- Space lef: Edit Format buffer
		vim.keymap.set('n', '<leader>lef', function()
			vim.lsp.buf.format { async = true }
		end, opts)
	end,
})

local foo = "abc"
foo = "def"
print(foo)
