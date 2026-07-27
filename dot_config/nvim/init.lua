-- ~/.config/nvim/init.lua
-- Leader : doit être défini avant tout require (les keymaps en dépendent)
vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

-- Désactiver netrw avant le chargement des plugins (oil.nvim le remplace)
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

require("options")
require("plugins")
require("autocmds")
require("keymaps")

-------------------------------------------------------------------------------
-- AIDE-MÉMOIRE (référence)
-- :checkhealth            → diagnostic complet de l'installation
-- :TSUpdate               → met à jour les parsers treesitter
-- :LspInfo                → état des serveurs LSP attachés au buffer
-- :LspInstallMissing      → installe les binaires LSP manquants
-- <leader>e               → yazi (explorateur flottant)
-- <leader>o / -           → oil.nvim (panneau droit / vinegar)
-- <leader>O               → oil.nvim (fenêtre flottante)
-- <leader>ff / fg / fb    → fichiers / grep / buffers (fzf-lua)
-- <leader>fh / fo / fr    → aide / récents / reprendre recherche (fzf-lua)
