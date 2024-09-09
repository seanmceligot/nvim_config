vim.g.mapleader = " "
vim.opt.clipboard = "unnamedplus"
vim.o.guifont = "Hack_Nerd_Font:h10" -- text below applies for VimScript
vim.cmd("colorscheme retrobox")
--vim.cmd("colorscheme quiet")
--vim.cmd("colorscheme habamax")

-- supposed to exit terminal input mode with leader ESC
--vim.api.nvim_set_keymap('t','<Leader><ESC>', '<C-\\><C-n>',{noremap = true})

--vim.api.nvim_set_keymap('n', ',c', ':only | horiz term cargo clippy<CR>', { noremap = true, silent = true })


vim.api.nvim_create_user_command('CargoSplit', function(opts)
	vim.cmd(':only | horiz term cargo ' .. opts.args)
end, { nargs = '+' })

-- :RipGrep 
vim.api.nvim_create_user_command('RipGrep', function(opts)
    -- Temporarily change grepprg to ripgrep for this command
    vim.cmd('set grepprg=rg\\ --vimgrep\\ -uu')
    vim.cmd('grep ' .. opts.args)
end, { nargs = '+' })

-- :GitGrep
vim.api.nvim_create_user_command('GitGrep', function(opts)
    -- Temporarily change grepprg to ripgrep for this command
    vim.cmd('set grepprg=git\\ --no-pager\\ grep\\ --no-color\\ -n')
    vim.cmd('set grepformat=%f:%l:%m,%m\\ %f\\ match%ts,%f')
    vim.cmd('grep ' .. opts.args)
end, { nargs = '+' })

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
		vim.o.timeoutlen = 300
	end,
	opts = {}
}

-- diffview :DiffViewOpen
local diffview_plugin   = {
	'sindrets/diffview.nvim'
}

-- TreeSitter :TSInstall
local treesitter_plugin = {
	'nvim-treesitter/nvim-treesitter',
	dependencies = {
	      'nvim-treesitter/nvim-treesitter-textobjects',
	},
}

-- rainbow csv
local rainbow_csv_plugin = {
    'cameron-wags/rainbow_csv.nvim',
    config = true,
    ft = {
        'csv',
        'tsv',
        'csv_semicolon',
        'csv_whitespace',
        'csv_pipe',
        'rfc_csv',
        'rfc_semicolon'
    },
    cmd = {
        'RainbowDelim',
        'RainbowDelimSimple',
        'RainbowDelimQuoted',
        'RainbowMultiDelim'
    }
}

-- telescope
local telescope_plugin = {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'BurntSushi/ripgrep',
        'sharkdp/fd'
    }
}

-- lazy
local plugins = { mason_plugin, which_key_plugin, diffview_plugin, treesitter_plugin, lspconfig_plugin, rainbow_csv_plugin, telescope_plugin }
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
	c = { "<cmd>CargoSplit clippy<cr>", "CargoSplit check" },
	r = { "<cmd>RipGrep <cword><cr>", "RipGrep <cword>" },
	g = { "<cmd>GitGrep <cword><cr>", "GitGrep <cword>" },
	d = { "<cmd>DiffviewOpen<cr>", "DiffView" },
	w = { "<cmd>WhichKey<cr>", "WhichKey" },
	m = { "<cmd>Mason<cr>", "Mason" },
	t = {
		name = "Treesitter",
		i = "incremental selection",
	},
	l = {
		name = "LSP",
		a = "action",
		K = "hover",
		F = "format entire file",
		R = "rename",
		r = "references",
		e = "diagnostics",
		D = "Declaration",
		d = "Definition",
		i = "implementation",
		p = "Previous diagnostics",
		n = "Next diagnostics",
		l = "List",
		h = "Hover",
		t = "Type",
		v = {
			name = "View",
		},
		w = {
			name = "Folder",
			l = "list", -- lwl
			a = "add", -- lwa
			r = "remove" -- lwr
		},
	},
    f = {
        name = "Telescope",
        f = { "<cmd>Telescope find_files<cr>", "Find Files" },
        g = { "<cmd>Telescope live_grep<cr>", "Live Grep" },
        b = { "<cmd>Telescope buffers<cr>", "Buffers" },
        h = { "<cmd>Telescope help_tags<cr>", "Help Tags" },
    },
}
wk.register(wk_mappings, { prefix = "<leader>" })

-- View (lv)
--
-- Space lvd: Open diagnostics
--
vim.keymap.set('n', '<leader>lD', vim.lsp.buf.declaration, opts)
vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition, opts)
vim.keymap.set('n', '<leader>le', vim.diagnostic.open_float)

-- Space lvp: Previous diagnostic error
vim.keymap.set('n', '<leader>lp', vim.diagnostic.goto_prev)

-- Space lvn: Next diagnostic error
vim.keymap.set('n', '<leader>ln', vim.diagnostic.goto_next)

-- Space lvl: Diagnostics location list
vim.keymap.set('n', '<leader>ll', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		-- :help omnnifunc defaults to: crtl-x ctrl o
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		-- Buffer local mappings
		local opts = { buffer = ev.buf }

		-- Go (Space lg)
		--
		-- Space lgr: Find references
		vim.keymap.set('n', '<leader>lr', vim.lsp.buf.references, opts)

		-- Space lgd: Jump to declaration int i
		vim.keymap.set('n', '<leader>lD', vim.lsp.buf.declaration, opts)

		-- Space lga: Jump to definition (assignement) var=val
		vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition, opts)

		-- Space lgi: Jump to implementation (gi)
		vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation, opts)


		-- View (Space lv)
		--
		-- Space lvh: Hover information
		vim.keymap.set('n', '<leader>lvh', vim.lsp.buf.hover, opts)
		-- alternate shift -k for hover
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', '<leader>lK', vim.lsp.buf.hover, opts)

		-- Space lvs: Signature help
		vim.keymap.set('n', '<leader>lt', vim.lsp.buf.signature_help, opts)

		-- Space lvt: Type definition
		vim.keymap.set('n', '<leader>lvt', vim.lsp.buf.type_definition, opts)

		-- Workspace (Space lw)
		--
		-- Add workspace folder
		vim.keymap.set('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder, opts)

		-- Remove workspace folder
		vim.keymap.set('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder, opts)

		-- List workspace folders
		vim.keymap.set('n', '<leader>lwl', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)

		-- Edit (Space le)
		vim.keymap.set('n', '<leader>lR', vim.lsp.buf.rename, opts)

		vim.keymap.set({ 'n', 'v' }, '<leader>la', vim.lsp.buf.code_action, opts)

		-- Space lef: Edit Format buffer
		vim.keymap.set('n', '<leader>lF', function()
			vim.lsp.buf.format { async = true }
		end, opts)
	end,
})

local treesitter_config = {
    ensure_installed = { 'lua', 'python', 'bash', 'rust', 'markdown', 'html' },

    auto_install = true,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<leader>ti',
        node_incremental = '<Enter>',
        scope_incremental = '<c-s>',
        node_decremental = '<BS>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next =  {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    }}
 require('nvim-treesitter.configs').setup(treesitter_config)


-- Telescope setup
local telescope = require('telescope')
telescope.setup({
    defaults = {
        -- ... (your Telescope configuration options here)
    }
})

vim.api.nvim_set_hl(0, '@lsp.typemod.variable.globalScope', { fg='white'})
vim.api.nvim_set_hl(0, '@lsp.type.parameter', { fg='Purple' })
vim.api.nvim_set_hl(0, '@lsp.type.property', { fg='crimson' })


