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
curl -fsSL https://raw.githubusercontent.com/steekell/dotfiles/v0.1.0/install.sh | sh
```

Branche `main` (dev) :

```sh
DOTFILES_REF=main curl -fsSL https://raw.githubusercontent.com/steekell/dotfiles/main/install.sh | sh
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/steekell/dotfiles/v0.1.0/install.ps1 | iex
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
| `DOTFILES_REF` | `main` | Branche ou tag git |
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
│   └── nvim/
│       └── init.lua
│
├── dot_ssh/
│   └── config.tmpl
│
├── dot_gitconfig.tmpl
├── dot_zshrc.tmpl
└── dot_vimrc
```

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

## Développement local

```sh
chezmoicd
chezmoi apply
chezmoi verify
```

## Licence

Privé / usage personnel sauf mention contraire.
