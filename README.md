# steekell/dotfiles

Dotfiles gérés avec [chezmoi](https://www.chezmoi.io/), installables en une ligne, **idempotents**, multiplateformes :

- Linux (dont WSL)
- macOS
- *BSD
- Windows

## Architecture (règle)

| Couche | Rôle | Où |
|---|---|---|
| **`install.sh` / `install.ps1`** | Démarrer chezmoi uniquement (binaire + `init`/`apply`) | racine du repo |
| **`.chezmoi.toml.tmpl` → `[data.system]`** | Faits stables : `os`, `arch`, `distro`, `distroLike` | `{{ .system.* }}` |
| **`.chezmoiscripts/`** | Configurer la machine | scripts `run_*` |
| **templates dots** | Fichiers user (`nvim`, `ssh/config`, `gitconfig`, …) | `dot_*` |

```text
.chezmoi.toml.tmpl     →  .system.os / arch / distro / distroLike
        ↓
00-bootstrap           →  dirs, state, probe PACKAGE_MANAGER
10-packages (onchange) →  PACKAGE_MANAGER live → apps
20-ssh (once)          →  ~/.ssh perms (pas de clés privées dans le repo)
        ↓  apply files
30-system (onchange)   →  tweaks OS/distro
90-finalize (after)    →  checks / hints chaque apply
```

- **`distro`** = stable (`chezmoi init`)
- **`PACKAGE_MANAGER`** = live dans les scripts qui en ont besoin
- **Secrets SSH** : jamais dans le repo (clés / known_hosts ignorés)

## Install

### Unix (Linux / macOS / BSD / WSL)

```sh
curl -fsSL https://raw.githubusercontent.com/steekell/dotfiles/v0.1.18/install.sh | sh
```

Branche `main` (dev) :

```sh
DOTFILES_REF=main curl -fsSL https://raw.githubusercontent.com/steekell/dotfiles/main/install.sh | sh
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/steekell/dotfiles/v0.1.18/install.ps1 | iex
```

Branche `main` :

```powershell
$env:DOTFILES_REF = 'main'
irm https://raw.githubusercontent.com/steekell/dotfiles/main/install.ps1 | iex
```

### Variables d’environnement (optionnel)

| Variable | Défaut | Rôle |
|---|---|---|
| `DOTFILES_REPO` | `https://github.com/steekell/dotfiles.git` | URL du dépôt |
| `DOTFILES_REF` | `v0.1.18` | Branche ou tag git (override pour `main` en dev) |
| `CHEZMOI_BIN_DIR` | `~/.local/bin` (Unix) / `%USERPROFILE%\bin` (Windows) | Binaire chezmoi si absent |

## Uninstall

Trois niveaux :

### `uninstall` (défaut)

- retire les **cibles managées** par chezmoi
- retire les **artefacts** (`~/.config/dotfiles`)
- **conserve** chezmoi et les données hors managed files

```sh
sh "$(chezmoi source-path)/uninstall.sh"
```

```powershell
& "$(chezmoi source-path)/uninstall.ps1"
```

### `--chezmoi-only` / `-ChezmoiOnly`

- source/config/cache chezmoi (+ binaire user-bin)
- **ne touche pas** aux fichiers déjà appliqués dans `$HOME`

### `--purge` / `-Purge`

- default + chezmoi-only (confirm : `-y` / `-Yes` / `DOTFILES_YES=1`)

## Structure

```text
dotfiles/
├── install.sh
├── install.ps1
├── uninstall.sh
├── uninstall.ps1
├── README.md
├── .chezmoi.toml.tmpl
├── .chezmoiignore
│
├── .chezmoiscripts/
│   ├── unix/
│   │   ├── run_once_before_00-bootstrap.sh.tmpl
│   │   ├── run_onchange_before_10-packages.sh.tmpl
│   │   ├── run_once_before_20-ssh.sh.tmpl
│   │   ├── run_onchange_30-system.sh.tmpl
│   │   └── run_after_90-finalize.sh.tmpl
│   │
│   └── windows/
│       ├── run_once_before_00-bootstrap.ps1.tmpl
│       ├── run_onchange_before_10-packages.ps1.tmpl
│       ├── run_once_before_20-ssh.ps1.tmpl
│       ├── run_onchange_30-system.ps1.tmpl
│       └── run_after_90-finalize.ps1.tmpl
│
├── dot_config/
│   ├── kanata/
│   │   └── kanata.kbd.tmpl      # → ~/.config/kanata/kanata.kbd (darwin vs linux/win)
│   ├── wezterm/
│   │   └── wezterm.lua          # → ~/.config/wezterm/wezterm.lua
│   ├── herdr/
│   │   └── config.toml          # → ~/.config/herdr/config.toml (défaut upstream)
│   ├── zellij/
│   │   └── config.kdl           # → ~/.config/zellij/config.kdl (dump upstream)
│   └── nvim/                    # → ~/.config/nvim (tous OS ; Windows via XDG_CONFIG_HOME)
│       ├── init.lua
│       ├── lua/
│       │   ├── options.lua
│       │   ├── plugins.lua
│       │   ├── autocmds.lua
│       │   └── keymaps.lua
│       ├── nvim-pack-lock.json
│       └── keys.md
│
├── dot_ssh/
│   └── config.tmpl
│
├── dot_gitconfig.tmpl
├── dot_zshrc.tmpl
└── dot_vimrc
```

Tous les dots sont **multiplateforme**. Neovim : un seul arbre XDG `~/.config/nvim` (pas de dual AppData) ; Windows pose `XDG_CONFIG_HOME` dans le bootstrap.

`install*` / `uninstall*` / `README.md` sont dans `.chezmoiignore` (pas copiés dans `$HOME`).

### Données template

```gotemplate
{{ .system.os }}
{{ .system.arch }}
{{ .system.distro }}
{{ .system.distroLike }}
{{ .name }}
{{ .email }}
```

Rafraîchir distro : `chezmoi init`.

## Après install

```sh
chezmoi status
chezmoi diff
chezmoi apply
chezmoi edit ~/.config/nvim/init.lua
```

### Terminal (WezTerm / Zellij / Herdr)

| Pièce | Chemin | Install binaire |
|---|---|---|
| WezTerm | `~/.config/wezterm/wezterm.lua` | `10-packages` (brew cask / winget) |
| Font | JetBrainsMono Nerd Font | `10-packages` (brew cask `font-jetbrains-mono-nerd-font`) |
| Zellij | `~/.config/zellij/config.kdl` (dump `zellij setup --dump-config`) | `ensure_cmd zellij` |
| Herdr | `~/.config/herdr/config.toml` (`herdr --default-config`) | `ensure_cmd herdr` |

Configs herdr/zellij = **origin upstream** (pas de custom maison). WezTerm = config user (font Nerd + keybinds).

### Kanata (clavier)

- Config : `~/.config/kanata/kanata.kbd` (managée ; source `kanata.kbd.tmpl`, branche macOS vs Linux/Windows)
- Binaire : installé par `10-packages` si absent (`kanata` via brew/apt/…)
- **macOS** dépendances hors brew (manuel, une fois) :
  1. Driver **Karabiner-DriverKit-VirtualHIDDevice v0.1.18** (pkg pqrs ; pas un brew package kanata)
  2. Activer l’extension : **Réglages → Général → Ouverture et extensions → Extensions de pilotes** → `org.pqrs.Karabiner-DriverKit-VirtualHIDDevice`
  3. Daemon VirtualHID (LaunchDaemon `org.pqrs.Karabiner-VirtualHIDDevice-Daemon` si pas Karabiner-Elements)
  4. Permissions pour le binaire `/opt/homebrew/Cellar/kanata/*/bin/kanata` :
     - Confidentialité → **Surveillance des entrées**
     - Confidentialité → **Accessibilité**
  5. Service :

```sh
sudo brew services start kanata
# logs: $(brew --prefix)/var/log/kanata.log
sudo brew services restart kanata   # après changement de permissions / driver
```

## Développement local

```sh
chezmoicd
chezmoi apply
chezmoi verify
```

## Licence

Privé / usage personnel sauf mention contraire.
