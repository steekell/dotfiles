<!-- ~/.config/nvim/keys.md -->

# Keymaps

Leader : `<Space>`

## Fenêtres

| Mode | Touches | Action |
|------|---------|--------|
| `n` | `<C-h/j/k/l>` | Navigation entre fenêtres |
| `n` | `<leader>wh/wj/wk/wl` | Focus gauche/bas/haut/droite |
| `n` | `<C-Up/Down>` | Resize hauteur ±2 |
| `n` | `<C-Left/Right>` | Resize largeur ±2 |
| `n` | `<leader>ws` | Split horizontal (bas) |
| `n` | `<leader>wv` | Split vertical (droite) |
| `n` | `<leader>wo` | Fermer les autres fenêtres (only) |
| `n` | `<leader>wd` | Fermer la fenêtre courante |

## Buffers

| Mode | Touches | Action |
|------|---------|--------|
| `n` | `[b` / `]b` | Buffer précédent / suivant |
| `n` | `<leader>bp/bn` | Buffer précédent / suivant |
| `n` | `<leader>bb` / `` <leader>` `` | Basculer vers l'autre buffer |
| `n` | `<leader>bd` | Supprimer le buffer courant |
| `n` | `<leader>bD` | Supprimer le buffer + fenêtre |
| `n` | `<leader>bo` | Supprimer les autres buffers |
| `n` | `<leader>bi` | Supprimer les buffers invisibles |

## Onglets

| Mode | Touches | Action |
|------|---------|--------|
| `n` | `<leader><tab><tab>` | Nouvel onglet |
| `n` | `<leader><tab>d` | Fermer l'onglet |
| `n` | `<leader><tab>o` | Fermer les autres onglets |
| `n` | `<leader><tab>n` | Onglet suivant |
| `n` | `<leader><tab>p` | Onglet précédent |
| `n` | `<leader><tab>]` / `[` | Onglet suivant / précédent (alias) |
| `n` | `<leader><tab>f` / `l` | Premier / dernier onglet |

## Édition

| Mode | Touches | Action |
|------|---------|--------|
| `n` | `<leader>qq` | Quitter tout |
| `n/v` | `J` / `K` | Déplacer la ligne/sélection |
| `n/v/i` | `<A-j>` / `<A-k>` | Déplacer la ligne/sélection (idem) |
| `x` | `<leader>p` | Coller sans écraser le registre (`"_dP`) |
| `n/v` | `<leader>y` | Copier vers clipboard système |
| `n` | `<leader>Y` | Copier la ligne vers clipboard |
| `x` | `<` / `>` | Indenter (conserve la sélection) |
| `n` | `<leader>fn` | Nouveau fichier |

## Commentaires (natifs nvim 0.10+)

| Mode | Touches | Action |
|------|---------|--------|
| `n` | `gcc` | Commenter/décommenter la ligne courante |
| `n` | `gc{motion}` | Commenter selon un mouvement (`gcap`, `gcG`, …) |
| `v` | `gc` | Commenter/décommenter la sélection |
| `n` | `gco` / `gcO` | Commentaire sur nouvelle ligne (sous / au-dessus) |

## Recherche

| Mode | Touches | Action |
|------|---------|--------|
| `i/n/s` | `<Esc>` | Effacer le surlignage et revenir en normal |
| `n` | `<leader>ur` | Redessiner + effacer hlsearch + diff update |
| `n/x/o` | `n` / `N` | Prochain / précédent résultat (direction-aware, centré) |
| `n` | `<C-d>` / `<C-u>` | Scroll centré |

## Quickfix / Location list

| Mode | Touches | Action |
|------|---------|--------|
| `n` | `[q` / `]q` | Quickfix précédent / suivant |
| `n` | `<leader>xq` | Toggle quickfix list |
| `n` | `<leader>xl` | Toggle location list |

## FZF (`fzf-lua`)

| Mode | Touches | Action |
|------|---------|--------|
| `n` | `<leader>ff` | Trouver un fichier |
| `n` | `<leader>fg` | Grep dans le projet |
| `n` | `<leader>fb` | Lister les buffers |
| `n` | `<leader>fh` | Aide Neovim |
| `n` | `<leader>fo` | Fichiers récents |
| `n` | `<leader>fr` | Reprendre la dernière recherche |

## Explorateurs de fichiers

| Mode | Touches | Action |
|------|---------|--------|
| `n` | `<leader>e` | Yazi (explorateur flottant) |
| `n` | `<leader>o` | oil.nvim (panneau droit 25 %) |
| `n` | `-` | oil.nvim (répertoire courant) |
| `n` | `<leader>O` | oil.nvim (flottant) |

## Terminal

| Mode | Touches | Action |
|------|---------|--------|
| `n` | `<leader>tt` | Terminal bas toggle (cwd) |
| `n` | `<leader>tr` | Terminal bas toggle (racine git) |
| `n/t` | `<C-/>` | Toggle terminal bas (racine git) |
| `n` | `<leader>th` | Terminal gauche 33 % toggle (cwd) |
| `n` | `<leader>tl` | Terminal droite 33 % toggle (cwd) |

## Git

| Mode | Touches | Action |
|------|---------|--------|
| `n` | `<leader>gl` / `gL` | Git log |
| `n` | `<leader>gf` | Historique du fichier courant |
| `n` | `<leader>gb` | Git blame ligne courante |
| `n/x` | `<leader>gB` | Ouvrir dans le navigateur (remote) |
| `n/x` | `<leader>gY` | Copier l'URL remote |

## Inspection

| Mode | Touches | Action |
|------|---------|--------|
| `n` | `<leader>ui` | Inspecter la position (treesitter/hl) |
| `n` | `<leader>uI` | Inspecter l'arbre treesitter |

## LSP (actif sur `LspAttach`, par buffer)

| Mode | Touches | Action |
|------|---------|--------|
| `n` | `<leader>cl` | LspInfo |
| `n` | `gd` | Définition (fzf) |
| `n` | `gD` | Déclaration |
| `n` | `gr` | Références (fzf) |
| `n` | `gI` | Implémentations (fzf) |
| `n` | `gy` | Définition de type (fzf) |
| `n` | `K` | Documentation (hover) |
| `n` | `gK` | Signature help |
| `i` | `<C-k>` | Signature help |
| `n` | `]]` / `[[` | Référence suivante / précédente |
| `n` | `<a-n>` / `<a-p>` | Référence suivante / précédente |
| `n/v` | `<leader>ca` | Code actions |
| `n/x` | `<leader>cf` | Formater (async) |
| `n/x` | `<leader>cA` | Source actions |
| `n` | `<leader>co` | Organiser les imports |
| `n` | `<leader>cr` | Renommer le symbole |
| `n` | `<leader>cR` | Renommer le fichier |
| `n/v` | `<leader>cc` | Exécuter codelens |
| `n` | `<leader>cC` | Rafraîchir codelens |
| `n` | `<leader>cd` | Diagnostic float |
| `n` | `]d` / `[d` | Diagnostic suivant / précédent |
| `n` | `]e` / `[e` | Erreur suivante / précédente |
| `n` | `]w` / `[w` | Warning suivant / précédent |
| `n` | `gai` | Appels entrants (fzf) |
| `n` | `gao` | Appels sortants (fzf) |
| `n` | `<leader>ss` | Symboles du document (fzf) |
| `n` | `<leader>sS` | Symboles workspace (fzf) |
