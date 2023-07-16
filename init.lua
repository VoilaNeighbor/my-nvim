-- Todo:
-- - Set up Lua & Vim LSP so I can program easier.
-- - Set up nvim tree.

vim.cmd [[
	let mapleader=" "

	set tabstop=2
	set shiftwidth=2

	set number
	set signcolumn=number

	set shell=powershell
	set shellcmdflag=-command
	set shellquote=\"
	set shellxquote=
]]

local diagnostics_config = {
	{ 'n', '<leader>dl', vim.diagnostic.setloclist },
	{ 'n', '<leader>dl', vim.diagnostic.setloclist },
	{ 'n', '<leader>df', vim.diagnostic.open_float },
	{ 'n', '[d', vim.diagnostic.goto_prev },
	{ 'n', ']d', vim.diagnostic.goto_next },
	{ 'n', 'gtD', vim.lsp.buf.type_definition },
	{ 'n', 'gD', vim.lsp.buf.declaration },
	{ 'n', 'gd', vim.lsp.buf.definition },
	{ 'n', 'gr', vim.lsp.buf.references },
	{ 'n', 'gi', vim.lsp.buf.implementation },
	{ 'n', 'K', vim.lsp.buf.hover },
	{ 'n', '<C-k>', vim.lsp.buf.signature_help },
	{ 'n', '<leader>wa', vim.lsp.buf.add_workspace_folder },
	{ 'n', '<leader>wr', vim.lsp.buf.remove_workspace_folder },
	{ 'n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end },
	{ 'n', '<leader>rn', vim.lsp.buf.rename },
	{ 'nv', '<leader>ca', vim.lsp.buf.code_action },
	{ 'n', '<leader>f', function() vim.lsp.buf.format { async = true } end },
}


-- # Implement IDE features.


-- Ensure lazy.nvim is installed and on the path.
local path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(path) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", path })
end
vim.opt.rtp:prepend(path)

local plugins = {
	{
		'williamboman/mason.nvim',
		build = ':MasonUpdate',
		-- lazy.nvim cannot setup Mason automatically. Maybe, is the name it detects wrong?
		config = function() require 'mason'.setup() end,
	},

	{
		'neovim/nvim-lspconfig',

		dependencies = {
			-- Load after mason to ensure that LSPs are configured well. Otherwise you might occassionally get "LSP Missing" errors.
			'williamboman/mason.nvim',
			'folke/neodev.nvim',
		},

		config = function()
			require 'neodev'.setup() -- Setup before lspconfig

			local lspconfig = require 'lspconfig'

			lspconfig.lua_ls.setup {
				settings = {
					Lua = {
						runtime = { version = 'LuaJIT' },
						telemetry = { enable = false },
					},
				},
			}

			for _, config in ipairs(diagnostics_config) do
				-- There seems to be a bug in LuaJIT, where table.unpack becomes nil, so I'm falling back to unpack.
				local modes, keystrokes, action = (table.unpack or unpack)(config)
				for mode in modes:gmatch '.' do
					vim.keymap.set(mode, keystrokes, action, { silent = true })
				end
			end
		end
	},

	{
		-- Configures lua_ls to know about nvim itself.
		'folke/neodev.nvim',
	},

}

require 'lazy'.setup(plugins, {})

