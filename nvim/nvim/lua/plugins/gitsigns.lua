return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      -- Distinguish staged hunks from unstaged ones so we can color them separately.
      signs_staged_enable = true,
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)

      -- Collapse the signcolumn down to 3 colors:
      -- red = removed, green = new/changed (unstaged), blue = staged.
      local function set_colors()
        local red, green, blue = "#e06c75", "#98c379", "#61afef"

        vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = green })
        vim.api.nvim_set_hl(0, "GitSignsChange", { fg = green })
        vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = green })
        vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = red })
        vim.api.nvim_set_hl(0, "GitSignsTopdelete", { fg = red })
        vim.api.nvim_set_hl(0, "GitSignsChangedelete", { fg = red })

        vim.api.nvim_set_hl(0, "GitSignsStagedAdd", { fg = blue })
        vim.api.nvim_set_hl(0, "GitSignsStagedChange", { fg = blue })
        vim.api.nvim_set_hl(0, "GitSignsStagedUntracked", { fg = blue })
        vim.api.nvim_set_hl(0, "GitSignsStagedDelete", { fg = blue })
        vim.api.nvim_set_hl(0, "GitSignsStagedTopdelete", { fg = blue })
        vim.api.nvim_set_hl(0, "GitSignsStagedChangedelete", { fg = blue })
      end

      set_colors()
      -- Reapply after any colorscheme switch, since it would otherwise
      -- overwrite these highlight groups with its own diff colors.
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_colors })
    end,
  },
}
