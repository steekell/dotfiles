-- lua/options.lua
local opt = vim.opt

-- Interface
opt.number         = true     -- numéros de ligne
opt.relativenumber = true     -- numéros relatifs
opt.signcolumn     = "yes"    -- colonne de signes toujours visible
opt.cursorline     = true     -- surligner la ligne courante
opt.colorcolumn    = '80,100' -- repères verticaux
opt.termguicolors  = true     -- couleurs 24 bits
opt.scrolloff      = 8        -- lignes de contexte autour du curseur
opt.splitright     = true     -- splits verticaux à droite
opt.splitbelow     = true     -- splits horizontaux en bas
opt.wrap           = true    -- retour automatique à la ligne
opt.list           = true     -- caractères invisibles
opt.listchars      = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars      = { eob = " ", fold = " ", foldopen = "▾", foldclose = "▸" }
opt.pumheight      = 12        -- hauteur du menu de complétion
opt.winborder      = "rounded" -- nvim 0.11+ : bordure par défaut des floats

-- Indentation
opt.expandtab   = true -- espaces plutôt que tabulations
opt.smartindent = true -- indentation automatique
opt.shiftwidth  = 2    -- largeur de l'indentation >> ou <<
opt.tabstop     = 2    -- largeur d'une tabulation
opt.softtabstop = 2    -- Tab ou Backspace agit par blocs de 2
opt.autoindent  = true -- indentation de la ligne précédente

-- Recherche
opt.ignorecase = true -- insensible à la casse
opt.smartcase  = true -- sensible si majuscule présente
opt.incsearch  = true -- recherche en direct
opt.hlsearch   = true -- surligner les résultats

-- Fichiers / historique
opt.fileencoding = 'utf-8' -- encodage par défaut
opt.undofile     = true    -- historique d'annulation persistant
opt.undolevels   = 10000   -- nombre d'actions stockées dans l'historique
opt.swapfile     = false   -- création du fichier .swp
opt.backup       = false   -- création du fichier de sauvegarde (fichier~)
opt.updatetime   = 250     -- temps d'inactivité
opt.timeoutlen   = 400     -- temps d'attente pour combinaison de touches
opt.autoread     = true    -- rechargement automatique si modification

-- Clipboard système (Linux/macOS/WSL)
opt.clipboard = "unnamedplus"

-- Complétion native (nvim 0.11+) : popup auto sans plugin
opt.completeopt  = { "menuone", "noselect", "popup", "fuzzy" }
vim.o.autocomplete = true -- nvim 0.12 : complétion auto native

-- Fold via treesitter natif
opt.foldmethod    = "expr"
opt.foldexpr      = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel     = 99
opt.foldlevelstart = 99

-- Mouse / divers
opt.mouse      = "a"
opt.confirm    = true
opt.inccommand = "split"
