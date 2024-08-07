-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- use `vim.keymap.set` instead
local map = LazyVim.safe_keymap_set

map("n", "gT", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "gt", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")
