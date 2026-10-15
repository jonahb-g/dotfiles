-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Note: LazyVim already maps <C-s> to save in insert/normal/visual mode, so it isn't repeated here.

vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>rc", "<cmd>source $MYVIMRC<CR>", { desc = "Reload config" })

-- Cmd+h/j/k/l is sent by WezTerm as Ctrl+h/j/k/l, which LazyVim already maps to window navigation.

-- Space tt toggles a terminal floating in the middle of the screen, like Space ff
vim.keymap.set("n", "<leader>tt", function()
  Snacks.terminal.toggle(nil, { win = { position = "float", width = 0.8, height = 0.8, border = "rounded" } })
end, { desc = "Floating terminal" })

-- Overrides LazyVim's default <Esc> behavior (clear search highlight) in normal mode
vim.keymap.set("n", "<Esc>", "i", { desc = "Toggle into insert mode" })
