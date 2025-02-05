local function set_numbers()
	vim.opt.number = true
	vim.opt.relativenumber = true
end

-- enable numbers in netrw
vim.api.nvim_create_autocmd('FileType', {
	pattern = 'netrw',
	callback = function ()
		set_numbers()
	end,
})

set_numbers()
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.wrap = false
-- so lsp doesn't shift the whole buffer to the right when there's an error
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.guifont = 'Cascadia Code:h8'
vim.opt.mouse = ''
vim.opt.hlsearch = false
vim.opt.ignorecase = true

-- begin lazy.nvim installation

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
	local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })

	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo(
			{
				{ 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
				{ out, 'WarningMsg' },
				{ '\nPress any key to exit...' },
			},
			true,
			{}
		)

		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
--vim.g.mapleader = ' '
--vim.g.manplocalleader = '\\'

-- end lazy.nvim installation

-- Setup lazy.nvim
require('lazy').setup {
	spec = {
		{
			'NMAC427/guess-indent.nvim',
		},
		{
			'lukas-reineke/indent-blankline.nvim',
			main = 'ibl',
		},
		{
			'windwp/nvim-autopairs',
			event = 'InsertEnter',
			config = true,
		},
		{
			'nvim-treesitter/nvim-treesitter',
			build = ':TSUpdate',
			config = function ()
				local configs = require('nvim-treesitter.configs')

				configs.setup {
					highlight = { enable = true },
					indent = { enable = true },
				}
			end
		},
		{
			'lewis6991/gitsigns.nvim',
		},
		{
			'neovim/nvim-lspconfig',
		},
		{
			'williamboman/mason.nvim',
		},
		{
			'williamboman/mason-lspconfig.nvim',
		},
		{
			'hrsh7th/cmp-nvim-lsp',
		},
		{
			'hrsh7th/cmp-buffer',
		},
		{
			'hrsh7th/cmp-path',
		},
		{
			'hrsh7th/cmp-cmdline',
		},
		{
			'hrsh7th/nvim-cmp',
			version = false,
			dependencies = {
				'hrsh7th/cmp-nvim-lsp',
				'hrsh7th/cmp-buffer',
				'hrsh7th/cmp-path',
			},
		},
		{
			'L3MON4D3/LuaSnip',
			version = 'v2.*',
			build = 'make install_jsregexp',
		},
		{
			'saadparwaiz1/cmp_luasnip',
		},
		{
			'Mofiqul/vscode.nvim',
			opts = {
				italic_comments = true,
				underline_links = true,
			},
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	-- install = { colorscheme = { 'habamax' } },
	-- automatically check for plugin updates
	checker = { enabled = true },
}

require('guess-indent').setup {}
require('ibl').setup()
require('gitsigns').setup()
require('mason').setup()

local ls = require 'luasnip'
local cmp = require 'cmp'

cmp.setup {
	snippet = {
		expand = function (args)
			ls.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert {
		['<C-Space>'] = cmp.mapping.complete(),
		['<CR>'] = cmp.mapping.confirm { select = true },
	},
	sources = cmp.config.sources(
	{
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	},
	{
		{ name = 'buffer' },
	}),
}

cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' },
	},
})

cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources(
	{
		{ name = 'path' }
	},
	{
		{ name = 'cmdline' },
	}),
	matching = { disallow_symbol_nonprefix_matching = false },
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require 'lspconfig'

local lsp_identifiers = {
	'lua_ls',
	'bashls',
	'clangd',
	'jedi_language_server',
	'gdscript',
	'ts_ls',
	'jsonls',
}

for _, k in pairs(lsp_identifiers) do
	lspconfig[k].setup {
		capabilities = capabilities,
	}
end

vim.diagnostic.config {
	signs = true,
	-- don't show diagnostics to the right of lines
	virtual_text = false,
}

-- custom keymaps

local my_keymaps = {
	{
		{ 'i' },
		'<C-S-Space>',
		function ()
			vim.lsp.buf.signature_help()
		end,
		nil,
	},
	{
		{ 'i', 'n' },
		'<F2>',
		function ()
			vim.lsp.buf.rename()
		end,
		nil,
	},
	{
		{ 'i', 'n', 'v' },
		'<leader>d',
		function ()
			vim.diagnostic.open_float()
		end,
		nil,
	},
	{
		{ 'i', 'n', 'v' },
		'<leader>g',
		function ()
			vim.lsp.buf.definition()
		end,
		nil,
	},
	{
		{ 'i', 'n', 'v' },
		'<leader>h',
		function ()
			vim.lsp.buf.hover()
		end,
		nil,
	},
	{
		{ 'i', 's' },
		'<C-L>',
		function ()
			ls.jump(1)
		end,
		{ silent = true },
	},
	{
		{ 'i', 's' },
		'<C-Right>',
		function ()
			ls.jump(1)
		end,
		{ silent = true },
	},
	{
		{ 'i', 's' },
		'<C-H>',
		function ()
			ls.jump(-1)
		end,
		{ silent = true },
	},
	{
		{ 'i', 's' },
		'<C-Left>',
		function ()
			ls.jump(-1)
		end,
		{ silent = true },
	},
}

for _, t in pairs(my_keymaps) do
	vim.keymap.set(unpack(t))
end

vim.cmd.colorscheme 'vscode'
