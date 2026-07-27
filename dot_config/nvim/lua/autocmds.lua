-- lua/autocmds.lua
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Surligne brièvement le texte copié/collé
vim.api.nvim_create_autocmd("TextYankPost", {
  group    = augroup,
  callback = function() vim.highlight.on_yank({ timeout = 150 }) end,
})

-- Retire les espaces de fin de ligne avant sauvegarde
vim.api.nvim_create_autocmd("BufWritePre", {
  group    = augroup,
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})

-- Restaure la position du curseur à l'ouverture d'un fichier
vim.api.nvim_create_autocmd("BufReadPost", {
  group    = augroup,
  callback = function()
    local mark   = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Ferme certains buffers utilitaires avec "q"
vim.api.nvim_create_autocmd("FileType", {
  group    = augroup,
  pattern  = { "help", "qf", "lspinfo", "checkhealth", "man" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})
