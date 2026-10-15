-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Note: LazyVim already maps <C-s> to save in insert/normal/visual mode, so it isn't repeated here.

vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>rc", "<cmd>source $MYVIMRC<CR>", { desc = "Reload config" })

-- Cmd+h/j/k/l (sent by WezTerm as Alt-h/j/k/l) move between windows
vim.keymap.set("n", "<M-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<M-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<M-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<M-l>", "<C-w>l", { desc = "Move to right window" })

-- Overrides LazyVim's default <Esc> behavior (clear search highlight) in normal mode
vim.keymap.set("n", "<Esc>", "i", { desc = "Toggle into insert mode" })
