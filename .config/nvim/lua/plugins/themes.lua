return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		version = false,
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme rose-pine")
		end,
	},
	{
		"neanias/everforest-nvim",
		version = false,
		--    lazy = false,
		--   priority = 1000,
		--   config = function()
		--     vim.cmd("colorscheme everforest")
		--   end,
	},
	{
		"folke/tokyonight.nvim",
		version = false,
		lazy = false,
		--		priority = 1000,
		--		config = function()
		--		vim.cmd("colorscheme tokyonight")
		--		end,
	},
}
