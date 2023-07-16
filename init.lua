-- Todo:
-- - Set up Lua & Vim LSP so I can program easier.
-- - Set up nvim tree.


vim.cmd [[
	set tabstop=2
	set shiftwidth=2

	set number
	set signcolumn=number

	set shell=powershell
	set shellcmdflag=-command
	set shellquote=\"
	set shellxquote=
]]


local function ensure_lazy_nvim()
	local path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not vim.loop.fs_stat(path) then
		vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", path })
	end
	vim.opt.rtp:prepend(path)
end


ensure_lazy_nvim()


-- Sometimes, lazy.nvim cannot setup a plugin automatically.
local plugins = {
	{
		'williamboman/mason.nvim',
		-- lazy.nvim cannot setup Mason automatically. The default config function does not work.
		config = function() require 'mason'.setup() end,
		build = ':MasonUpdate',
	},

	{
		'neovim/nvim-lspconfig',
		dependencies = {
			-- Load after mason to ensure that LSPs are configured well. Otherwise you might occassionally get "LSP Missing" errors.
			'williamboman/mason.nvim',
		},
		config = function()
			local lspconfig = require 'lspconfig'
			lspconfig.lua_ls.setup {
				settings = {
					Lua = {
						runtime = { version = 'LuaJIT' },
						diagnostics = { globals = { 'vim' } },
						telemetry = { enable = false },
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
						},
					},
				},
			}
		end
	},
}

require 'lazy'.setup(plugins, {})

