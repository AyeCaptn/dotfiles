-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

opt.tabstop = 4
vim.g.snacks_animate = false

vim.g.lazyvim_python_lsp = "ty"

-- Set snacks as the default picker for LazyVim
vim.g.lazyvim_picker = "snacks"

-- Enable this option to avoid conflicts with Prettier.
vim.g.lazyvim_prettier_needs_config = true

vim.g.sidekick_nes = false

-- Native inline completions don't support being shown as regular completions
vim.g.ai_cmp = false
