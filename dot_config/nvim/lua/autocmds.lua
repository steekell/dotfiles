-- lua/autocmds.lua
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Chezmoi: map *.tmpl → host filetype (dot_zshrc.tmpl, foo.sh.tmpl, …)
-- Priority > default "template"/gotmpl so Treesitter uses the real language.
local tmpl_ext = {
  sh = "bash",
  bash = "bash",
  zsh = "zsh",
  ps1 = "ps1",
  lua = "lua",
  toml = "toml",
  yml = "yaml",
  yaml = "yaml",
  json = "json",
  md = "markdown",
  kdl = "kdl",
  conf = "conf",
  vim = "vim",
  tmux = "tmux",
  kbd = "lisp", -- kanata
}

vim.filetype.add({
  pattern = {
    [".*%.tmpl"] = {
      function(path, _)
        local base = path:gsub("%.tmpl$", "")
        local name = base:match("([^/\\]+)$") or base

        if name:find("zshrc", 1, true)
          or name:find("zprofile", 1, true)
          or name:find("zlogin", 1, true)
          or name:find("zshenv", 1, true)
        then
          return "zsh"
        end
        if name:find("bashrc", 1, true)
          or name:find("bash_profile", 1, true)
          or name:find("bash_aliases", 1, true)
        then
          return "bash"
        end
        if name:find("gitconfig", 1, true) then
          return "gitconfig"
        end
        if name == "config" and (
          base:find("[/\\]%.?ssh[/\\]")
          or base:find("[/\\]dot_ssh[/\\]")
          or base:find("dot_ssh[/\\]")
        ) then
          return "sshconfig"
        end
        if name:find("chezmoi.toml", 1, true) then
          return "toml"
        end

        local ext = name:match("%.([%w]+)$")
        if ext and tmpl_ext[ext] then
          return tmpl_ext[ext]
        end
      end,
      { priority = 200 },
    },
  },
})

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
