-- BEGIN ~/.config/nvim/init.lua --

vim.g.mapleader = " "
vim.opt.clipboard = "unnamedplus"
vim.o.guifont = "Hack_Nerd_Font:h10" -- text below applies for VimScript
vim.cmd("colorscheme desert")

--------- BEGIN CycleColorScheme ------
local colorschemes = vim.fn.getcompletion('', 'color')
local colorscheme_index = 1

function CycleColorScheme()
    colorscheme_index = colorscheme_index + 1
    if colorscheme_index > #colorschemes then
        colorscheme_index = 1
    end
    vim.cmd('colorscheme ' .. colorschemes[colorscheme_index])
    print('Colorscheme: ' .. colorschemes[colorscheme_index])
end
-- Map ,c
vim.keymap.set('n', ',c', CycleColorScheme, { noremap = true, silent = true })
--------- END CycleColorScheme ------
--------- BEGIN ReplaceSmilies -------
function ReplaceSmilies()
    -- Search and replace [x] with [😎] in the current buffer
    vim.api.nvim_command('%s/\\[x\\]/[😎]/g')
end

-- Create a command :ReplaceSmilies to call the function
vim.api.nvim_create_user_command('ReplaceSmilies', ReplaceSmilies, {})

---

--------- END ReplaceSmilies ------
---
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

-- which key configuration
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
		K = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Show Documentation (hover)" },
		r = { "<cmd>lua vim.lsp.buf.references()<cr>", "Find References" },
		d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Go to Definition" },
		i = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Go to Implementation" },
		R = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename Symbol" },
		a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
		f = { "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", "Format Code" },
		e = { "<cmd>lua vim.diagnostic.open_float()<cr>", "Show Diagnostics" },
		n = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next Diagnostic" },
		p = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Previous Diagnostic" },
		t = { "<cmd>lua vim.lsp.buf.type_definition()<cr>", "Type Definition" },
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
-- Register global mappings
wk.register({
    -- Your global mappings here, for example:
    ["<C-p>"] = { "<cmd>Telescope find_files<cr>", "Find Files" },
    ["<C-n>"] = { "<cmd>enew<cr>", "New File" },
    ["<C-s>"] = { "<cmd>w<cr>", "Save File" },
    ["<C-x>"] = { "<cmd>q<cr>", "Quit" },
}, { prefix = "" })  -- Empty prefix for global mappings

-- Optional: Create a shortcut to show global mappings with <leader><leader>
wk.register({
    ["<leader><leader>"] = {
        function()
            wk.show("", { mode = "n" })  -- Show all global mappings in normal mode
        end,
        "Show Global Mappings",
    },
})

-- Treesitter configuration
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
        lookahead = true,
        keymaps = {
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
        set_jumps = true,
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


-- LSP keybindings
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		-- :help omnnifunc defaults to: crtl-x ctrl o
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		-- Buffer local mappings
		local opts = { buffer = ev.buf }

		-- Go to references (gr)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

		-- Go to declaration (gD)
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)

		-- Go to definition (gd)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

		-- Go to implementation (gi)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)

		-- Hover documentation (K)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

		-- Rename symbol (<leader>rn)
		vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

		-- Code actions (<leader>ca)
		vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)

		-- Format code (<leader>cf)
		vim.keymap.set('n', '<leader>cf', function()
			vim.lsp.buf.format { async = true }
		end, opts)

		-- Diagnostics

		-- Show diagnostics in floating window (<leader>e)
		vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)

		-- Go to next diagnostic (]d)
		vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

		-- Go to previous diagnostic ([d)
		vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)

		-- Set location list to show diagnostics (<leader>q)
		vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
	end,
})

-- END ~/.config/nvim/init.lua --

