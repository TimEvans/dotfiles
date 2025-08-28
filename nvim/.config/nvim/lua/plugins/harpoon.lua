return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
    vim.keymap.set("n", "<C-e>", function() 
      harpoon.ui:toggle_quick_menu(harpoon:list())
      
      -- Add number key mappings after a short delay to ensure the menu is open
      vim.defer_fn(function()
        local bufnr = vim.api.nvim_get_current_buf()
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        
        -- Check if we're in the harpoon menu buffer
        if string.match(bufname, "harpoon") then
          vim.keymap.set("n", "1", function()
            harpoon:list():select(1)
          end, { buffer = bufnr, silent = true })
          
          vim.keymap.set("n", "2", function()
            harpoon:list():select(2)
          end, { buffer = bufnr, silent = true })
          
          vim.keymap.set("n", "3", function()
            harpoon:list():select(3)
          end, { buffer = bufnr, silent = true })
          
          vim.keymap.set("n", "4", function()
            harpoon:list():select(4)
          end, { buffer = bufnr, silent = true })
        end
      end, 10)
    end)

    vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
    vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
    vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
    vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

    vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
    vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
  end,
}
