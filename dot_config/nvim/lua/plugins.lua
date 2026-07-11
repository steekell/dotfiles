-- lua/plugins.lua
-- vim.pack, Treesitter, colorscheme, fzf-lua, oil.nvim
-- LSP natif (vim.lsp.config / vim.lsp.enable — nvim 0.11+)
-- Auto-install des binaires LSP manquants

-------------------------------------------------------------------------------
-- Plugins

vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/bluz71/vim-moonfly-colors" },
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/folke/flash.nvim" },
  { src = "https://github.com/mzlogin/vim-markdown-toc" },
  { src = "https://github.com/folke/which-key.nvim" },
})

-- Recompile treesitter après update via vim.pack
vim.api.nvim_create_autocmd("PackChanged", {
  desc = "Recompile treesitter après update via vim.pack",
  callback = function(ev)
    if ev.data and ev.data.spec and ev.data.spec.name == "nvim-treesitter" then
      vim.cmd("TSUpdate")
    end
  end,
})

require("nvim-treesitter").setup()
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "python", "bash" },
  callback = function()
    local ok, err = pcall(vim.treesitter.start)
    if not ok then
      vim.notify("treesitter: " .. err, vim.log.levels.WARN)
    end
  end,
})

vim.cmd.colorscheme("moonfly")
vim.api.nvim_set_hl(0, "Normal",      { bg = "#000000" })
vim.api.nvim_set_hl(0, "NormalNC",    { bg = "#000000" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })

require("fzf-lua").setup({
  winopts = { height = 0.85, width = 0.85, border = "rounded" },
  grep = {
    -- Ripgrep : fichiers cachés inclus, smart-case, colonnes limitées
    rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob=!.git/ --max-columns=4096 -e",
  },
})

require("oil").setup({
  default_file_explorer = true, -- remplace netrw comme explorateur par défaut
  delete_to_trash       = true, -- suppression vers la corbeille système
  view_options = {
    show_hidden = true,         -- affiche les fichiers cachés (dotfiles)
  },
  float = {
    padding = 2,
    border  = "rounded",
  },
  keymaps = {
    ["<C-s>"] = false,              -- libère C-s
    ["<C-r>"] = "actions.refresh",
    ["<CR>"]  = {
      desc = "Ouvrir dans le buffer à gauche",
      callback = function()
        local oil   = require("oil")
        local entry = oil.get_cursor_entry()
        if not entry then return end
        if entry.type == "directory" then
          oil.open(oil.get_current_dir() .. entry.name)
          return
        end
        local path    = oil.get_current_dir() .. entry.name
        local oil_win = vim.api.nvim_get_current_win()
        vim.cmd("wincmd h")
        if vim.api.nvim_get_current_win() == oil_win then
          vim.cmd("aboveleft vsplit")
        end
        vim.cmd("edit " .. vim.fn.fnameescape(path))
      end,
    },
  },
})

require("flash").setup()

-------------------------------------------------------------------------------
-- LSP natif

vim.lsp.config["lua_ls"] = {
  cmd          = { "lua-language-server" },
  filetypes    = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  settings     = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace   = { checkThirdParty = false },
      telemetry   = { enable = false },
    },
  },
}

vim.lsp.config["pyright"] = {
  cmd          = { "pyright-langserver", "--stdio" },
  filetypes    = { "python" },
  root_markers = { "pyproject.toml", "setup.py", ".git" },
}

vim.lsp.config["ts_ls"] = {
  cmd          = { "typescript-language-server", "--stdio" },
  filetypes    = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", ".git" },
}

vim.lsp.config["bashls"] = {
  cmd          = { "bash-language-server", "start" },
  filetypes    = { "sh", "bash" },
  root_markers = { ".git" },
}

vim.lsp.config["jsonls"] = {
  cmd          = { "vscode-json-language-server", "--stdio" },
  filetypes    = { "json", "jsonc" },
  root_markers = { ".git" },
}

vim.lsp.config["marksman"] = {
  cmd          = { "marksman", "server" },
  filetypes    = { "markdown" },
  root_markers = { ".git", ".marksman.toml" },
}

-------------------------------------------------------------------------------
-- Auto-install des binaires LSP manquants
-- Détecte pacman > apt > dnf > zypper, repli npm.
-- Déclencheur manuel : :LspInstallMissing

local lsp_pkg_map = {
  lua_ls   = { pacman = "lua-language-server",        apt = "lua-language-server", dnf = "lua-language-server", zypper = "lua-language-server", npm = nil },
  pyright  = { pacman = "pyright",                    apt = nil, dnf = nil, zypper = nil, npm = "pyright" },
  ts_ls    = { pacman = "typescript-language-server", apt = nil, dnf = nil, zypper = nil, npm = "typescript-language-server" },
  bashls   = { pacman = "bash-language-server",       apt = nil, dnf = nil, zypper = nil, npm = "bash-language-server" },
  jsonls   = { pacman = "vscode-json-languageserver", apt = nil, dnf = nil, zypper = nil, npm = "vscode-langservers-extracted" },
  marksman = { pacman = "marksman",                   apt = nil, dnf = nil, zypper = nil, npm = nil },
}

local function detect_pkg_manager()
  for _, m in ipairs({ "pacman", "apt", "dnf", "zypper" }) do
    if vim.fn.executable(m) == 1 then return m end
  end
  return nil
end

local function install_cmd_for(manager, pkg)
  if manager == "pacman" then return { "sudo", "pacman", "-S", "--noconfirm", pkg } end
  if manager == "apt"    then return { "sudo", "apt-get", "install", "-y", pkg } end
  if manager == "dnf"    then return { "sudo", "dnf", "install", "-y", pkg } end
  if manager == "zypper" then return { "sudo", "zypper", "--non-interactive", "install", pkg } end
  return nil
end

local function missing_servers()
  local servers = { "lua_ls", "pyright", "ts_ls", "bashls", "jsonls", "marksman" }
  local missing = {}
  for _, name in ipairs(servers) do
    if vim.fn.executable(vim.lsp.config[name].cmd[1]) == 0 then
      table.insert(missing, name)
    end
  end
  return missing
end

local function enable_available_servers()
  local servers  = { "lua_ls", "pyright", "ts_ls", "bashls", "jsonls", "marksman" }
  local to_enable = {}
  for _, name in ipairs(servers) do
    if vim.fn.executable(vim.lsp.config[name].cmd[1]) == 1 then
      table.insert(to_enable, name)
    end
  end
  if #to_enable > 0 then vim.lsp.enable(to_enable) end
end

enable_available_servers()

local function install_missing_lsp(silent)
  local missing = missing_servers()
  if #missing == 0 then
    if not silent then vim.notify("LSP : tous les binaires sont déjà présents.", vim.log.levels.INFO) end
    return
  end
  local manager = detect_pkg_manager()
  local npm_ok  = vim.fn.executable("npm") == 1
  for _, name in ipairs(missing) do
    local pkgs = lsp_pkg_map[name]
    local pkg  = manager and pkgs[manager] or nil
    if pkg then
      local cmd = install_cmd_for(manager, pkg)
      vim.notify(("LSP : installation de %s via %s (%s)…"):format(name, manager, pkg), vim.log.levels.INFO)
      vim.system(cmd, { text = true }, function(res)
        vim.schedule(function()
          if res.code == 0 then
            vim.notify(("LSP : %s installé."):format(name), vim.log.levels.INFO)
          else
            vim.notify(("LSP : échec install %s (code %d). Voir :messages."):format(name, res.code), vim.log.levels.WARN)
          end
          enable_available_servers()
        end)
      end)
    elseif pkgs.npm and npm_ok then
      vim.notify(("LSP : installation de %s via npm (%s)…"):format(name, pkgs.npm), vim.log.levels.INFO)
      vim.system({ "npm", "install", "-g", pkgs.npm }, { text = true }, function(res)
        vim.schedule(function()
          if res.code == 0 then
            vim.notify(("LSP : %s installé via npm."):format(name), vim.log.levels.INFO)
          else
            vim.notify(("LSP : échec npm install %s (code %d)."):format(name, res.code), vim.log.levels.WARN)
          end
          enable_available_servers()
        end)
      end)
    else
      vim.notify(("LSP : aucun paquet connu pour %s sur ce système (installer manuellement)."):format(name), vim.log.levels.WARN)
    end
  end
end

-- Signale au démarrage les binaires manquants (non-intrusif)
vim.api.nvim_create_autocmd("VimEnter", {
  once     = true,
  callback = function()
    local missing = missing_servers()
    if #missing > 0 then
      vim.notify(
        "LSP manquants : " .. table.concat(missing, ", ") .. "  →  :LspInstallMissing pour installer",
        vim.log.levels.WARN
      )
    end
  end,
})

vim.api.nvim_create_user_command("LspInstallMissing", function()
  install_missing_lsp(false)
end, { desc = "Installe les binaires LSP manquants (pacman/apt/dnf/zypper ou npm)" })

-- UI diagnostics
vim.diagnostic.config({
  virtual_text  = { spacing = 2, prefix = "●" },
  severity_sort = true,
  underline     = true,
  float         = { border = "rounded", source = true },
  signs         = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "",
    },
  },
})

-------------------------------------------------------------------------------
-- which-key

require("which-key").setup({
  delay = 500,
  icons = { mappings = false },
})

require("which-key").add({
  { "<leader>a",      group = "Actions" },
  { "<leader>at",     group = "Table of contents" },
  { "<leader>b",      group = "Buffers" },
  { "<leader>e",      group = "Explorateur" },
  { "<leader>f",      group = "Fichiers / Recherche" },
  { "<leader>g",      group = "Git" },
  { "<leader>l",      group = "LSP" },
  { "<leader>o",      group = "Oil" },
  { "<leader>q",      group = "Quitter" },
  { "<leader>t",      group = "Terminal" },
  { "<leader>u",      group = "UI" },
  { "<leader>w",      group = "Fenêtres" },
  { "<leader>x",      group = "Diagnostics" },
  { "<leader><tab>",  group = "Onglets" },
})
