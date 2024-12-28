--------------------------------------------------------------------------------
-- BEGIN ~/.config/nvim/init.lua
--------------------------------------------------------------------------------

-- Set <Space> as the global leader key. This must happen before plugins load.
vim.g.mapleader = " "

-- Use the system clipboard for all yank, delete, change, and put operations.
vim.opt.clipboard = "unnamedplus"

-- Set the GUI font (for Neovim in a GUI environment like Neovide or VimR).
vim.o.guifont = "Hack_Nerd_Font:h10"

-- Use the built-in "desert" colorscheme by default.
vim.cmd("colorscheme desert")


--------------------------------------------------------------------------------
-- BASIC KEYBINDINGS
--------------------------------------------------------------------------------

-- In Insert mode, <C-x><C-o> triggers Neovim's built-in "omnicompletion"
-- (like a manual completion request). In Zed, you'd typically have 
-- auto-suggestions, but here we can replicate a manual trigger.
vim.keymap.set("i", "<C-x><C-o>", "<C-x><C-o>", { desc = "Open completion (omni)" })

-- In Insert mode, <C-x><C-z> will hide or dismiss current completion suggestions 
-- by passing an empty completion list. This is akin to "escape completion" in Zed.
vim.keymap.set("i", "<C-x><C-z>", function()
  vim.fn.complete(0, {})
end, { desc = "Hide all suggestions" })


--------------------------------------------------------------------------------
-- CycleColorScheme
--
-- Cycle through all installed color schemes by pressing ",c".
--------------------------------------------------------------------------------

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

-- Press ",c" in Normal mode to cycle through color schemes
vim.keymap.set('n', ',c', CycleColorScheme, { noremap = true, silent = true })


--------------------------------------------------------------------------------
-- ReplaceSmilies
--
-- Example command that replaces "[x]" with "[😎]" in the buffer.
--------------------------------------------------------------------------------

function ReplaceSmilies()
    -- Search and replace [x] with [😎] in the current buffer
    vim.api.nvim_command('%s/\\[x\\]/[😎]/g')
end

-- Create a command :ReplaceSmilies to call the function
vim.api.nvim_create_user_command('ReplaceSmilies', ReplaceSmilies, {})


--------------------------------------------------------------------------------
-- CargoSplit
--
-- Creates a horizontal terminal and runs a cargo command, e.g. :CargoSplit build
--------------------------------------------------------------------------------

vim.api.nvim_create_user_command('CargoSplit', function(opts)
	vim.cmd(':only | horiz term cargo ' .. opts.args)
end, { nargs = '+' })


--------------------------------------------------------------------------------
-- RipGrep
--
-- Sets the 'grepprg' to ripgrep with vimgrep-compatible output, then runs :grep.
--------------------------------------------------------------------------------

vim.api.nvim_create_user_command('RipGrep', function(opts)
    vim.cmd('set grepprg=rg\\ --vimgrep\\ -uu')
    vim.cmd('grep ' .. opts.args)
end, { nargs = '+' })


--------------------------------------------------------------------------------
-- GitGrep
--
-- Similar to :RipGrep but sets 'grepprg' to run git grep. Use :GitGrep <args>.
--------------------------------------------------------------------------------

vim.api.nvim_create_user_command('GitGrep', function(opts)
    vim.cmd('set grepprg=git\\ --no-pager\\ grep\\ --no-color\\ -n')
    vim.cmd('set grepformat=%f:%l:%m,%m\\ %f\\ match%ts,%f')
    vim.cmd('grep ' .. opts.args)
end, { nargs = '+' })


--------------------------------------------------------------------------------
-- LAZY.NVIM BOOTSTRAP
--
-- Lazy is a plugin manager that we clone and place on the runtime path.
--------------------------------------------------------------------------------

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


--------------------------------------------------------------------------------
-- PLUGIN DECLARATIONS FOR LAZY
--------------------------------------------------------------------------------

-- Mason: for managing external LSP servers, formatters, etc. (:Mason)
local mason_plugin      = {
	"williamboman/mason.nvim",
	'williamboman/mason-lspconfig.nvim'
}

-- LSP + Neodev: native LSP configurations + special config for Neovim Lua dev.
local lspconfig_plugin  = {
	"neovim/nvim-lspconfig",
	"folke/neodev.nvim",
}

-- Which-key: interactive help for keybindings. (:WhichKey)
local which_key_plugin  = {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	opts = {}
}

-- Diffview: git diffs in a side-by-side view. (:DiffViewOpen)
local diffview_plugin   = {
	'sindrets/diffview.nvim'
}

-- TreeSitter: better syntax highlighting, text objects, incremental selection.
local treesitter_plugin = {
	'nvim-treesitter/nvim-treesitter',
	dependencies = {
	      'nvim-treesitter/nvim-treesitter-textobjects',
	},
}

-- Rainbow CSV: highlight CSV/TSV files by columns.
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

-- Telescope: fuzzy finder for files, buffers, LSP symbols, and more.
local telescope_plugin = {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'BurntSushi/ripgrep',
        'sharkdp/fd'
    }
}

-- Gather all plugin tables and set them up with lazy
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


--------------------------------------------------------------------------------
-- MASON & LSP SETUP
--------------------------------------------------------------------------------

-- Neodev must be set up before LSP config to properly handle .lua files.
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
-- We use "which-key" to provide a helpful popup of available keybinds.
-- Zed-like keybinds are grouped under "g" (for LSP commands).
--------------------------------------------------------------------------------

local wk = require("which-key")

-- Mappings prefixed by <leader>
local wk_mappings = {
    -- Press <leader> + c to run cargo clippy via :CargoSplit
	c = { "<cmd>CargoSplit clippy<cr>", "CargoSplit check" },
	-- Press <leader> + r to run ripgrep on the word under cursor
	r = { "<cmd>RipGrep <cword><cr>", "RipGrep <cword>" },
	-- Press <leader> + g to run git grep on the word under cursor
	g = { "<cmd>GitGrep <cword><cr>", "GitGrep <cword>" },
	-- Press <leader> + d to open DiffView
	d = { "<cmd>DiffviewOpen<cr>", "DiffView" },
	-- Press <leader> + w to open WhichKey help
	w = { "<cmd>WhichKey<cr>", "WhichKey" },
	-- Press <leader> + m to open Mason UI
	m = { "<cmd>Mason<cr>", "Mason" },
	-- Press <leader> + t then i to trigger incremental selection
	t = {
		name = "Treesitter",
		i = "incremental selection",
	},
}

-- Zed-like LSP keybinds under 'g' prefix in normal mode
-- (like `g d` for definition, `g h` for hover, etc.).
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

-- Also register some global mappings (no prefix)
wk.register({
    -- Press Ctrl-p to open file finder
    ["<C-p>"] = { "<cmd>Telescope find_files<cr>", "Find Files" },
    -- Press Ctrl-n to open a new empty file (like "New file" in Zed)
    ["<C-n>"] = { "<cmd>enew<cr>", "New File" },
    -- Press Ctrl-s to save the current file (like "Save" in Zed)
    ["<C-s>"] = { "<cmd>w<cr>", "Save File" },
    -- Press Ctrl-x to quit (like "Close file" in Zed)
    ["<C-x>"] = { "<cmd>q<cr>", "Quit" },
}, { prefix = "" })

-- Optional: Show the global mappings with <leader><leader>
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
      -- Start incremental selection: <leader> + t + i
      init_selection = '<leader>ti',
      -- Expand the selection by pressing <Enter>
      node_incremental = '<Enter>',
      -- Expand selection to the scope by pressing Ctrl-s
      scope_incremental = '<c-s>',
      -- Shrink selection by pressing Backspace
      node_decremental = '<BS>',
    },
  },

  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        -- "aa" => outer parameter, "ia" => inner parameter, etc.
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',

        -- Zed-like approach: "gc" => outer comment text object
        ['gc'] = '@comment.outer',

        -- HTML-like tags if available
        ['at'] = '@tag.outer',
        ['it'] = '@tag.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- Use jumplist on normal movements
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
      swap_next = {
        -- Move to next parameter
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        -- Move to previous parameter
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
        -- You can configure prompt behavior, sorting, etc. here.
    }
})

-- Example custom highlight groups for LSP
vim.api.nvim_set_hl(0, '@lsp.typemod.variable.globalScope', { fg='white'})
vim.api.nvim_set_hl(0, '@lsp.type.parameter', { fg='Purple' })
vim.api.nvim_set_hl(0, '@lsp.type.property', { fg='crimson' })


--------------------------------------------------------------------------------
-- LSP KEYBINDINGS (BUFFER-LOCAL)
--
-- Use an Autocmd so these are set only when an LSP actually attaches.
-- They mirror the "gX" style from Zed, but are specifically buffer-local.
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		-- Use omnifunc for completion
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
		local opts = { buffer = ev.buf }

		-- Zed-style LSP navigation:
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)        -- g d: Go to definition
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)       -- g D: Go to declaration
		vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)   -- g y: Go to type definition
		vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, opts)    -- g I: Go to implementation

		-- Zed-like rename: "c d" => "change definition"
		vim.keymap.set('n', 'cd', vim.lsp.buf.rename, opts)

		-- g A: Show all references
		vim.keymap.set('n', 'gA', vim.lsp.buf.references, opts)

		-- g s: Find symbol in current file (uses Telescope)
		vim.keymap.set('n', 'gs', "<cmd>Telescope lsp_document_symbols<cr>", opts)

		-- g S: Find symbol in entire workspace (uses Telescope)
		vim.keymap.set('n', 'gS', "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", opts)

		-- g ]: Jump to next diagnostic (or ]d)
		vim.keymap.set('n', 'g]', vim.diagnostic.goto_next, opts)
		-- g [: Jump to previous diagnostic (or [d)
		vim.keymap.set('n', 'g[', vim.diagnostic.goto_prev, opts)

		-- g h: Hover info (like inline error or doc in Zed)
		vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)

		-- g .: Show code actions
		vim.keymap.set('n', 'g.', vim.lsp.buf.code_action, opts)
	end,
})

--------------------------------------------------------------------------------
-- END ~/.config/nvim/init.lua
--------------------------------------------------------------------------------

