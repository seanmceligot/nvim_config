--------------------------------------------------------------------------------
-- BEGIN ~/.config/nvim/init.lua
--------------------------------------------------------------------------------

vim.g.mapleader = " "
vim.opt.clipboard = "unnamedplus"
vim.o.guifont = "Hack_Nerd_Font:h10"
vim.cmd("colorscheme desert")


-- c-X C-O completion
vim.keymap.set("i", "<C-x><C-o>", "<C-x><C-o>", { desc = "Open completion (omni)" })

-- Hide suggestions or do something else:
vim.keymap.set("i", "<C-x><C-z>", function()
  vim.fn.complete(0, {})
end, { desc = "Hide all suggestions" })

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
--------- END ReplaceSmilies ------

vim.api.nvim_create_user_command('CargoSplit', function(opts)
	vim.cmd(':only | horiz term cargo ' .. opts.args)
end, { nargs = '+' })

-- :RipGrep 
vim.api.nvim_create_user_command('RipGrep', function(opts)
    vim.cmd('set grepprg=rg\\ --vimgrep\\ -uu')
    vim.cmd('grep ' .. opts.args)
end, { nargs = '+' })

-- :GitGrep
vim.api.nvim_create_user_command('GitGrep', function(opts)
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
local plugins = {
  mason_plugin,
  which_key_plugin,
  diffview_plugin,
  treesitter_plugin,
  lspconfig_plugin,
  rainbow_csv_plugin,
  telescope_plugin
}
require("lazy").setup(plugins)

-- mason and lsp
require("neodev").setup()
require("mason").setup()
require("mason-lspconfig").setup()
local lspconfig = require('lspconfig')

-- :h mason-lspconfig-automatic-server-setup
require("mason-lspconfig").setup_handlers {
	function(server_name) -- default handler
		lspconfig[server_name].setup {}
	end,
}

--------------------------------------------------------------------------------
-- WHICH-KEY CONFIGURATION
--
-- Zed-like keybinds where possible.
--------------------------------------------------------------------------------
local wk = require("which-key")

local wk_mappings = {
    -- Existing top-level keys:
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

    -- Add a new top-level table for 'g' so it behaves like Zed’s LSP keys
    -- (in which-key, having `g = {...}` under `prefix = "<leader>"` won't give us plain `gX`.
    -- Instead, we can do *global* mappings or register them as you prefer. 
    -- If you want plain `g d`, `g D`, etc. to appear in WhichKey, use a separate `wk.register` with `prefix = "g"`.
}

local zed_lsp_mappings = {
    name = "LSP (Zed-style)",
    d = { "<cmd>lua vim.lsp.buf.definition()<cr>",         "Go to definition" },
    D = { "<cmd>lua vim.lsp.buf.declaration()<cr>",        "Go to declaration" },
    y = { "<cmd>lua vim.lsp.buf.type_definition()<cr>",    "Go to type definition" },
    I = { "<cmd>lua vim.lsp.buf.implementation()<cr>",     "Go to implementation" },
    A = { "<cmd>lua vim.lsp.buf.references()<cr>",         "All references" },
    s = { "<cmd>Telescope lsp_document_symbols<cr>",       "Symbol in current file" },
    S = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Symbol in entire project" },
    ["]"] = { "<cmd>lua vim.diagnostic.goto_next()<cr>",   "Next diagnostic" },
    ["["] = { "<cmd>lua vim.diagnostic.goto_prev()<cr>",   "Previous diagnostic" },
    h = { "<cmd>lua vim.lsp.buf.hover()<cr>",              "Show inline error (hover)" },
    ["."] = { "<cmd>lua vim.lsp.buf.code_action()<cr>",    "Code actions" },
}

-- Register <leader>-prefixed mappings
wk.register(wk_mappings, { prefix = "<leader>" })

-- Register the "g" prefix for LSP
wk.register(zed_lsp_mappings, { prefix = "g" })

-- Also register some global mappings
wk.register({
    ["<C-p>"] = { "<cmd>Telescope find_files<cr>", "Find Files" },
    ["<C-n>"] = { "<cmd>enew<cr>", "New File" },
    ["<C-s>"] = { "<cmd>w<cr>", "Save File" },
    ["<C-x>"] = { "<cmd>q<cr>", "Quit" },
}, { prefix = "" })

-- Optional: Show global mappings
wk.register({
    ["<leader><leader>"] = {
        function()
            wk.show("", { mode = "n" })
        end,
        "Show Global Mappings",
    },
})

--------------------------------------------------------------------------------
-- TREESITTER CONFIG
--------------------------------------------------------------------------------
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
        -- Original mappings
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',

        -- Zed-like additions
        ['gc'] = '@comment.outer', -- For text object “a comment” (g c in Zed)
        -- Tag text objects (if your grammar supports HTML-like tags):
        ['at'] = '@tag.outer',
        ['it'] = '@tag.inner',
        --
        -- The “indent-level” text objects (aI, iI, etc.) are not standard in
        -- nvim-treesitter-textobjects. You’d need a custom query or plugin
        -- if you want to replicate Zed’s aI, iI, ii exactly.
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      -- Original movement
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
      --
      -- NOTE: Zed’s “go to next/previous comment” ( `] /`, `] *`, `[ /`, `[ *` )
      -- is not built-in. You’d need a custom capture or plugin that handles
      -- comment motion. We’re not removing anything though, just noting it’s
      -- not standard in nvim-treesitter-textobjects.
    },
    swap = {
      -- Keep your original swap mappings
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Finally, set up Treesitter with the combined config
require('nvim-treesitter.configs').setup(treesitter_config)

--------------------------------------------------------------------------------
-- TELESCOPE SETUP
--------------------------------------------------------------------------------
local telescope = require('telescope')
telescope.setup({
    defaults = {
        -- your Telescope configuration here
    }
})

vim.api.nvim_set_hl(0, '@lsp.typemod.variable.globalScope', { fg='white'})
vim.api.nvim_set_hl(0, '@lsp.type.parameter', { fg='Purple' })
vim.api.nvim_set_hl(0, '@lsp.type.property', { fg='crimson' })

--------------------------------------------------------------------------------
-- ACTUAL LSP KEYBINDINGS (BUFFER-LOCAL)
-- We override them to match Zed shortcuts exactly.
--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		-- Use omnifunc for completion
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
		local opts = { buffer = ev.buf }

		-- Zed-style bindings:

		-- Go to definition: g d
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

		-- Go to declaration: g D
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)

		-- Go to type definition: g y
		vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)

		-- Go to implementation: g I
		vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, opts)

		-- Rename (change definition): c d
		vim.keymap.set('n', 'cd', vim.lsp.buf.rename, opts)

		-- Go to all references: g A
		vim.keymap.set('n', 'gA', vim.lsp.buf.references, opts)

		-- Find symbol in current file: g s
		--   -> For best results, use Telescope's lsp_document_symbols
		vim.keymap.set('n', 'gs', "<cmd>Telescope lsp_document_symbols<cr>", opts)

		-- Find symbol in entire project: g S
		vim.keymap.set('n', 'gS', "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", opts)

		-- Go to next diagnostic: g ] (and/or ]d)
		vim.keymap.set('n', 'g]', vim.diagnostic.goto_next, opts)
		-- Go to previous diagnostic: g [ (and/or [d)
		vim.keymap.set('n', 'g[', vim.diagnostic.goto_prev, opts)

		-- Show inline error (hover): g h
		vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)

		-- Open the code actions menu: g .
		vim.keymap.set('n', 'g.', vim.lsp.buf.code_action, opts)

	end,
})

--------------------------------------------------------------------------------
-- END ~/.config/nvim/init.lua
--------------------------------------------------------------------------------

