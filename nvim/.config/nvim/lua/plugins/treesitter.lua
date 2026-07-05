-- Parsers to keep installed. `markdown` / `markdown_inline` are required by
-- render-markdown.nvim, which is what surfaced the original crash.
local ensure_installed = {
  "c",
  "lua",
  "python",
  "javascript",
  "typescript",
  "bash",
  "json",
  "markdown",
  "markdown_inline",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- The `master` branch is frozen and incompatible with Neovim 0.11+.
    -- The `main` branch is the rewrite that supports current Neovim.
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    },
    config = function()
      require("nvim-treesitter").setup({})

      -- Parser installation on `main` requires the `tree-sitter` CLI. Only
      -- attempt it when the CLI is present; otherwise Neovim's bundled parsers
      -- (c, lua, markdown, markdown_inline, vim, vimdoc, query) still work.
      if vim.fn.executable("tree-sitter") == 1 then
        require("nvim-treesitter").install(ensure_installed)
      else
        vim.notify(
          "nvim-treesitter (main): `tree-sitter` CLI not found; parsers cannot be "
            .. "installed/updated. Install it with: sudo pacman -S tree-sitter-cli",
          vim.log.levels.WARN
        )
      end

      -- On `main`, highlighting and indentation are enabled per buffer rather
      -- than through `highlight`/`indent` modules. Highlighting comes from
      -- Neovim core (`vim.treesitter.start`); indentation from this plugin.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          -- Only enable when a parser is available for this buffer.
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- Textobjects (main branch API).
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true, -- jump forward to the textobject, targets.vim style
        },
      })

      local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
      local textobjects = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      }
      for lhs, capture in pairs(textobjects) do
        vim.keymap.set({ "x", "o" }, lhs, function()
          select_textobject(capture, "textobjects")
        end, { desc = "Select " .. capture })
      end

      -- Incremental selection was removed from `main`; reimplemented natively.
      -- (The former scope-increment mapping `grc` has no native equivalent and
      -- is dropped.)
      local inc = require("config.ts-incremental")
      vim.keymap.set("n", "gnn", inc.init_selection, { desc = "TS: init selection" })
      vim.keymap.set("x", "grn", inc.node_incremental, { desc = "TS: grow to parent node" })
      vim.keymap.set("x", "grm", inc.node_decremental, { desc = "TS: shrink node selection" })
    end,
  },
}
