-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.scrolloff = 8 -- LazyVim default is 4

-- Relative line numbers, with the absolute number on the cursor line
vim.opt.number = true
vim.opt.relativenumber = true

-- Show the file path at the top of each window
vim.opt.winbar = "%f"

-- Don't auto-fold code (blank lines were being shown as closed 1-line
-- folds, rendered as a dashed "---" line instead of just blank).
vim.opt.foldenable = false
vim.opt.fillchars:append({ fold = " " })

-- Make syntax/lint errors impossible to miss: red underline under the
-- offending code plus a red message inline at end of line.
vim.diagnostic.config({
  underline = true,
  virtual_text = { spacing = 4, prefix = "●" },
  signs = true,
  severity_sort = true,
})
