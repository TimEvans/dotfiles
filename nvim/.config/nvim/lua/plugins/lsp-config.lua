return {
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "mason-org/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        auto_install = true,
        ensure_installed = { "lua_ls", "pyright" }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    -- Keep for LSP utilities and keymaps
    config = function()
      -- Use vim.lsp.config for server setup
      vim.lsp.config('lua_ls', {})
      vim.lsp.config('pyright', {})

      -- LSP keymaps
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, {})

      -- Enable LSP servers
      vim.lsp.enable({ 'lua_ls', 'pyright' })
    end
  }
}
