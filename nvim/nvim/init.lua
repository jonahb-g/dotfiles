vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8

-- Show the file path at the top of each window
vim.opt.winbar = "%f"

-- Save current file (Word-style Ctrl+S, plus <leader>w)
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>rc", "<cmd>source $MYVIMRC<CR>", { desc = "Reload config" })

-- Cmd+h / Cmd+l (sent by WezTerm as Alt-h/Alt-l) move between windows
vim.keymap.set("n", "<M-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<M-l>", "<C-w>l", { desc = "Move to right window" })
vim.keymap.set("n", "<Esc>", "i", { desc = "Toggle into insert mode" })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function()
      require("rose-pine").setup({ variant = "moon" })
      vim.cmd("colorscheme rose-pine")
    end,
  },
  { "nvim-tree/nvim-web-devicons" },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find by grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({})
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({})
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({ "python", "lua", "javascript", "typescript", "json", "markdown" })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python", "lua", "javascript", "typescript", "json", "markdown" },
        callback = function() vim.treesitter.start() end,
      })
    end,
  },
})
