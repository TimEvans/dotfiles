return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = "nvim-treesitter/nvim-treesitter-textobjects",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "c", "lua", "python", "javascript", "typescript", "bash", "json" },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner", 
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
        },
      }
    end,
  }
}

