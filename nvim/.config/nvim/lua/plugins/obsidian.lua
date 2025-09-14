return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    conceallevel = 2,
    workspaces = {
      {
        name = "personal",
        path = "~/Github/magnetic_rose/",
      },
    },
    templates = {  -- Move this inside opts
      subdir = "Templates", -- This is relative to your workspace path
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },
  },
}
