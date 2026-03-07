return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons", -- optional but recommended for icons
  },
  opts = {
    -- Headings - different styles for each level
    headings = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },

    -- Checkbox states
    checkbox = {
      unchecked = { icon = "󰄱 " },
      checked = { icon = " " },
    },

    -- Code blocks
    code = {
      style = "full", -- or "normal" for less emphasis
      left_pad = 2,
      right_pad = 2,
    },

    -- Bullet points
    bullets = { "●", "○", "◆", "◇" },

    -- Quote blocks
    quote = { icon = "▎" },

    -- Tables
    pipe_table = {
      style = "full",
      cell = "padded",
    },

    -- Toggle on/off with :RenderMarkdown toggle
    -- Start enabled or disabled
    enabled = true,
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)

    -- Optional: Add keybinding to toggle
    vim.keymap.set("n", "<leader>md", ":RenderMarkdown toggle<CR>", { desc = "Toggle Markdown Rendering" })
  end,
}
