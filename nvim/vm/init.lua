-- Personal Neovim configuration.
-- Plugins use Neovim native packages; no LazyVim or plugin manager.
-- Add custom settings here as you decide what you want.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Cmd+h/j/k/l moves between windows. Over SSH the terminal must forward Cmd, or
-- translate it to Ctrl, so both modifiers are accepted.
for _, key in ipairs({ "h", "j", "k", "l" }) do
  for _, lhs in ipairs({ "<D-" .. key .. ">", "<C-" .. key .. ">" }) do
    vim.keymap.set({ "n", "t" }, lhs, "<cmd>wincmd " .. key .. "<cr>", {
      desc = "Move to window " .. key,
    })
  end
end

-- Review local Git changes against the last commit.
vim.cmd("packadd diffview.nvim")

-- Opening a file's diff jumps to its first change. ]c / [c step through changes
-- and carry on into the next / previous file; Tab / Shift-Tab switch files.
local diff_jump = "first"
local function jump_to_change(winid, where)
  vim.api.nvim_set_current_win(winid)
  if where == "last" then
    vim.cmd("normal! G")
    if vim.fn.diff_hlID(vim.fn.line("."), 1) == 0 then
      vim.cmd("normal! [c")
    end
  else
    vim.cmd("normal! gg")
    if vim.fn.diff_hlID(1, 1) == 0 then
      vim.cmd("normal! ]c")
    end
  end
end
local function step_change(dir)
  local before = vim.fn.line(".")
  vim.cmd("normal! " .. (dir > 0 and "]c" or "[c"))
  if vim.fn.line(".") ~= before then
    return
  end
  diff_jump = dir > 0 and "first" or "last"
  require("diffview.actions")[dir > 0 and "select_next_entry" or "select_prev_entry"]()
end

require("diffview").setup({
  use_icons = false,
  view = { default = { layout = "diff2_horizontal" } },
  hooks = {
    diff_buf_win_enter = function(_, winid, ctx)
      -- Show complete files and keep the two sides aligned while scrolling.
      vim.wo[winid].foldenable = false
      vim.wo[winid].scrollbind = true
      vim.wo[winid].cursorbind = true
      vim.wo[winid].wrap = false
      -- Land on the first (or, going backwards, last) change in the new side.
      if ctx.symbol == "b" then
        local where = diff_jump
        diff_jump = "first"
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(winid) then
            jump_to_change(winid, where)
          end
        end)
      end
    end,
  },
  keymaps = {
    view = {
      { "n", "]c", function() step_change(1) end, { desc = "Next change, continuing into the next file" } },
      { "n", "[c", function() step_change(-1) end, { desc = "Previous change, continuing into the previous file" } },
    },
  },
  file_panel = {
    listing_style = "list",
    win_config = { position = "left", width = 38 },
  },
})
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen HEAD<cr>", { desc = "Review local changes" })
vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close changes review" })

-- Fuzzy filename search from the repository root, or current directory.
vim.cmd("packadd plenary.nvim")
vim.cmd("packadd telescope.nvim")
require("telescope").setup({
  defaults = { color_devicons = false },
  pickers = { find_files = { hidden = true, file_ignore_patterns = { "^%.git/" } } },
})
vim.keymap.set("n", "<leader>ff", function()
  local root = vim.fs.root(0, ".git") or vim.fs.root(vim.fn.getcwd(), ".git") or vim.fn.getcwd()
  require("telescope.builtin").find_files({ cwd = root })
end, { desc = "Find files" })

-- Search the whole project for text (ripgrep). Cmd+Shift+f in WezTerm sends Alt+F.
local function project_root()
  return vim.fs.root(0, ".git") or vim.fs.root(vim.fn.getcwd(), ".git") or vim.fn.getcwd()
end
local function project_grep()
  require("telescope.builtin").live_grep({ cwd = project_root() })
end
vim.keymap.set("n", "<leader>fg", project_grep, { desc = "Search project for text" })
vim.keymap.set({ "n", "i" }, "<M-F>", project_grep, { desc = "Search project for text" })
vim.keymap.set("n", "<leader>fw", function()
  require("telescope.builtin").grep_string({ cwd = project_root() })
end, { desc = "Search project for word under cursor" })

-- Use installed Tree-sitter parsers to distinguish functions, parameters,
-- keywords, strings, and comments without changing the colorscheme.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("PersonalSyntaxHighlighting", { clear = true }),
  callback = function(event)
    -- Keep built-in syntax highlighting for filetypes without a parser.
    pcall(vim.treesitter.start, event.buf)
  end,
})

-- The diff panes show full files; unchanged sections are not folded.

-- VS Code-like colors, retaining the dark background from the minimal setup.
vim.cmd("packadd vscode.nvim")
require("vscode").setup({
  style = "dark",
  italic_comments = false,
  italic_inlayhints = false,
  terminal_colors = false,
  color_overrides = { vscBack = "#14161b" },
})
local function remove_italics()
  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if hl.italic then
      hl.italic = false
      vim.api.nvim_set_hl(0, name, hl)
    end
  end
end
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("PersonalNoItalics", { clear = true }),
  callback = remove_italics,
})
vim.cmd.colorscheme("vscode")
vim.opt.cursorline = true
vim.opt.laststatus = 3
vim.opt.showmode = false
vim.opt.statusline = " %{mode()}  %f %m%r %= %y  %l:%c  %p%% "
vim.opt.winbar = "%f %m"

-- Neovim normally ignores scrollbind when wheeling over an unfocused window.
-- Focus a hovered diff pane first, then forward the original wheel event.
for _, key in ipairs({ "<ScrollWheelDown>", "<ScrollWheelUp>", "<ScrollWheelLeft>", "<ScrollWheelRight>" }) do
  vim.keymap.set("n", key, function()
    local win = vim.fn.getmousepos().winid
    if win ~= 0 and vim.api.nvim_win_is_valid(win) and vim.wo[win].diff then
      vim.api.nvim_set_current_win(win)
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", false)
  end, { desc = "Scroll hovered diff pane with both sides linked" })
end

-- Relative line numbers, with the absolute number on the cursor line.
vim.opt.relativenumber = true

-- Space tt toggles a terminal floating in the middle of the screen, like Space ff.
local float_term = { buf = nil, win = nil }
local function toggle_float_term()
  if float_term.win and vim.api.nvim_win_is_valid(float_term.win) then
    vim.api.nvim_win_hide(float_term.win)
    float_term.win = nil
    return
  end
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  if not (float_term.buf and vim.api.nvim_buf_is_valid(float_term.buf)) then
    float_term.buf = vim.api.nvim_create_buf(false, true)
    vim.keymap.set({ "t", "n" }, "<Esc>", toggle_float_term, { buffer = float_term.buf, desc = "Hide floating terminal" })
  end
  float_term.win = vim.api.nvim_open_win(float_term.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })
  if vim.bo[float_term.buf].buftype ~= "terminal" then
    vim.fn.jobstart(vim.o.shell, { term = true })
  end
  vim.cmd.startinsert()
end
vim.keymap.set("n", "<leader>tt", toggle_float_term, { desc = "Floating terminal" })

-- GitLens-style blame (author, age, commit message) at the end of the cursor line.
vim.cmd("packadd gitsigns.nvim")
require("gitsigns").setup({
  current_line_blame = true,
  current_line_blame_opts = { delay = 300 },
  current_line_blame_formatter = "<author>, <author_time:%R> • <summary>",
})

-- Cmd+c / Cmd+f from WezTerm arrive as Alt+c / Alt+f. Copies go out over OSC 52
-- (through tmux) to the macOS clipboard. Cmd+v is a WezTerm paste, so reading "+
-- returns what nvim last copied instead of asking the terminal.
local osc52 = require("vim.ui.clipboard.osc52")
local last_copy = { {}, "v" }
local function copy_to(reg)
  local send = osc52.copy(reg)
  return function(lines, regtype)
    last_copy = { lines, regtype }
    send(lines, regtype)
  end
end
local function paste_last_copy()
  return last_copy
end
vim.g.clipboard = {
  name = "OSC 52",
  copy = { ["+"] = copy_to("+"), ["*"] = copy_to("*") },
  paste = { ["+"] = paste_last_copy, ["*"] = paste_last_copy },
}
vim.keymap.set("x", "<M-c>", '"+y', { desc = "Copy selection to system clipboard" })
vim.keymap.set("n", "<M-f>", "/", { desc = "Search in file" })
vim.keymap.set("i", "<M-f>", "<Esc>/", { desc = "Search in file" })

-- Mouse back / forward buttons, like a browser: Karabiner turns them into Alt+o /
-- Alt+i while WezTerm is in front (karabiner/ in dotfiles); they walk the jump list.
vim.keymap.set("n", "<M-o>", "<C-o>", { desc = "Jump back" })
vim.keymap.set("n", "<M-i>", "<C-i>", { desc = "Jump forward" })
vim.keymap.set("i", "<M-o>", "<Esc><C-o>", { desc = "Jump back" })
vim.keymap.set("i", "<M-i>", "<Esc><C-i>", { desc = "Jump forward" })

-- Python language server (`uv tool install basedpyright`, or `brew install basedpyright` on macOS) so gd
-- follows imports across files. Imports resolve from the git root, its .venv,
-- and Bazel's generated code in bazel-bin (e.g. *_pb2 modules).
vim.lsp.config("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { ".git", "pyproject.toml" },
  settings = {
    basedpyright = {
      analysis = {
        -- Navigation and hover only; skip type-checking noise in the editor.
        typeCheckingMode = "off",
        diagnosticMode = "openFilesOnly",
      },
    },
  },
  before_init = function(_, config)
    local root = config.root_dir
    if not root then
      return
    end
    if vim.uv.fs_stat(root .. "/.venv/bin/python") then
      config.settings.python = { pythonPath = root .. "/.venv/bin/python" }
    end
    if vim.uv.fs_stat(root .. "/bazel-bin") then
      config.settings.basedpyright.analysis.extraPaths = { root .. "/bazel-bin" }
    end
  end,
})
vim.lsp.enable("basedpyright")
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("PersonalLsp", { clear = true }),
  callback = function(event)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = event.buf, desc = "Go to definition" })
  end,
})
