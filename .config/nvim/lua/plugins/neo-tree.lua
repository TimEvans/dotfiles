return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  lazy = false,
  config = function()
    require("neo-tree").setup({
      -- Add your options here
      close_if_last_window = true,
      enable_git_status = true,
      enable_diagnostics = true,
      filesystem = {
        follow_current_file = { enabled = true },
      },
    })
    -- Optional: keybinding
    vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", { desc = "Toggle NeoTree" })
  end,
}
