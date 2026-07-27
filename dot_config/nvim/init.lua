-- ~/.config/nvim/init.lua
-- Minimal starter — extend as needed.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Swap/backup under XDG state (not repo)
local state = vim.fn.stdpath("state")
vim.opt.directory = state .. "/swap//"
vim.opt.undodir = state .. "/undo//"
vim.opt.backupdir = state .. "/backup//"
for _, d in ipairs({ "swap", "undo", "backup" }) do
  vim.fn.mkdir(state .. "/" .. d, "p")
end

-- Basic keymaps
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Write" })
vim.keymap.set("n", "<leader>q", "<cmd>quitall<cr>", { desc = "Quit" })
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>", { silent = true })
