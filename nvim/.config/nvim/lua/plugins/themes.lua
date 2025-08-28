return {

  {
    "neanias/everforest-nvim",
    version = false,
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme everforest")
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine-moon",
    version = false,
    --	lazy = false,
    --	priority = 1000,
    --	config = function()
    --		vim.cmd("colorscheme rose-pine-moon ")
    --	end,
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
