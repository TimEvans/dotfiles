return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function()
    -- The build runs before ft/cmd lazy-loading has sourced the plugin's autoload functions
    require("lazy").load({ plugins = { "markdown-preview.nvim" } })
    vim.fn["mkdp#util#install"]()
  end,
  config = function()
    -- Optional configuration
    vim.g.mkdp_theme = "dark"
    vim.g.mkdp_filetypes = { "markdown" }
    
    -- Keybindings
    vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", { desc = "Start Markdown Preview" })
    vim.keymap.set("n", "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", { desc = "Stop Markdown Preview" })
  end,
}
