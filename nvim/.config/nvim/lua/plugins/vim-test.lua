return {
  "vim-test/vim-test",
  dependencies = {
    "preservim/vimux",
  },
  vim.keymap.set("n", "<leader>t", ":TestNearest<CR>"),
  vim.keymap.set("n", "<leader>a", ":TestSuit<CR>"),
  vim.keymap.set("n", "<leader>l", ":TestLast<CR>"),
  vim.keymap.set("n", "<leader>q", ":TestVisit<CR>"),
  vim.cmd("let test#strategy = 'vimux'"),
}
