-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.cmd("autocmd VimEnter * hi Normal ctermbg=NONE guibg=NONE")
vim.api.nvim_set_keymap(
  "n",
  "<leader>a",
  ':lua require("api_tester").create_test_buffer()<CR>',
  { noremap = true, silent = true }
)
