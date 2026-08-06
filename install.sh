#!/bin/sh
# Start chezmoi only — does NOT configure the machine.
# Machine setup lives in .chezmoiscripts/ (run via chezmoi apply).
#
# Idempotent. Override: DOTFILES_REPO, DOTFILES_REF, CHEZMOI_BIN_DIR
#
#   curl -fsSL https://raw.githubusercontent.com/steekell/dotfiles/v0.2.1/install.sh | sh
#   DOTFILES_REF=main curl -fsSL .../install.sh | sh
set -eu

REPO_URL="${DOTFILES_REPO:-https://github.com/steekell/dotfiles.git}"
# Pin to this release by default (override: DOTFILES_REF=main).
DEFAULT_REF="v0.2.1"
REF="${DOTFILES_REF:-$DEFAULT_REF}"
BIN_DIR="${CHEZMOI_BIN_DIR:-$HOME/.local/bin}"
export PATH="${BIN_DIR}:${PATH}"

info() { printf '%s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

ask_install_kanata() {
	if [ -n "${DOTFILES_INSTALL_KANATA:-}" ]; then
		return 0
	fi
	# /dev/tty may exist but be unopenable (no controlling terminal, e.g. some
	# CI/containers, or curl|sh with stdin already consumed) — fall back safely.
	if { printf 'Install kanata (keyboard remapper)? [y/N] ' >/dev/tty && read -r ans </dev/tty; } 2>/dev/null; then
		case "$ans" in
			y | Y | yes | YES) DOTFILES_INSTALL_KANATA=1 ;;
			*) DOTFILES_INSTALL_KANATA=0 ;;
		esac
	else
		# Non-interactive: do not install unless explicitly requested.
		DOTFILES_INSTALL_KANATA=0
	fi
	export DOTFILES_INSTALL_KANATA
}

need_cmd() {
	command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

install_chezmoi() {
	if command -v chezmoi >/dev/null 2>&1; then
		info "chezmoi already installed: $(command -v chezmoi)"
		return 0
	fi

	info "installing chezmoi into ${BIN_DIR}..."
	mkdir -p "$BIN_DIR"

	if command -v brew >/dev/null 2>&1; then
		brew install chezmoi
		command -v chezmoi >/dev/null 2>&1 || die "chezmoi install via brew failed"
		info "chezmoi installed: $(command -v chezmoi)"
		return 0
	fi

	need_cmd curl
	# Official installer (Linux, macOS, *BSD, WSL).
	sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$BIN_DIR"
	command -v chezmoi >/dev/null 2>&1 || die "chezmoi install failed"
	info "chezmoi installed: $(command -v chezmoi)"
}

source_path() {
	if command -v chezmoi >/dev/null 2>&1; then
		chezmoi source-path 2>/dev/null || printf '%s\n' "${HOME}/.local/share/chezmoi"
	else
		printf '%s\n' "${HOME}/.local/share/chezmoi"
	fi
}

init_or_update() {
	sp=$(source_path)

	if [ -d "${sp}/.git" ]; then
		info "existing chezmoi source at ${sp} — updating (ref=${REF})..."
		backup_path="${sp}.bak.$(date -u +%Y%m%dT%H%M%SZ 2>/dev/null || date +%Y%m%d%H%M%S).$$"
		info "backing up chezmoi source to ${backup_path}"
		cp -a "$sp" "$backup_path" ||
			die "cannot back up chezmoi source before fetch"
		if command -v git >/dev/null 2>&1; then
			if git -C "$sp" remote get-url origin >/dev/null 2>&1; then
				git -C "$sp" remote set-url origin "$REPO_URL" ||
					die "cannot configure origin remote in ${sp}"
			else
				git -C "$sp" remote add origin "$REPO_URL" ||
					die "cannot add origin remote in ${sp}"
			fi
			fetch_git() {
				case "$REF" in
					v*)
						git -C "$sp" fetch origin \
							"+refs/tags/${REF}:refs/tags/${REF}"
						;;
					*)
						git -C "$sp" fetch origin \
							"+refs/heads/${REF}:refs/remotes/origin/${REF}"
						;;
				esac
			}
			if ! GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null fetch_git; then
				die "cannot fetch ${REPO_URL}; refusing to apply stale chezmoi source"
			fi
			if git -C "$sp" rev-parse --verify "refs/tags/${REF}" >/dev/null 2>&1; then
				git -C "$sp" checkout -q -f "tags/${REF}" ||
					die "cannot checkout tag ${REF}"
			elif git -C "$sp" rev-parse --verify "refs/remotes/origin/${REF}" >/dev/null 2>&1; then
				git -C "$sp" checkout -q -f -B "$REF" "origin/${REF}" ||
					die "cannot checkout branch ${REF}"
			elif git -C "$sp" rev-parse --verify "refs/heads/${REF}" >/dev/null 2>&1; then
				git -C "$sp" checkout -q -f "$REF" ||
					die "cannot checkout local ref ${REF}"
			else
				die "ref '${REF}' not found in ${REPO_URL}"
			fi
		fi
		chezmoi apply --keep-going
		return 0
	fi

	info "initializing chezmoi from ${REPO_URL} (ref=${REF})..."
	need_cmd git
	# --branch accepts branch or tag names.
	chezmoi init --apply --branch "$REF" "$REPO_URL"
}

main() {
	ask_install_kanata
	info "dotfiles install — start chezmoi only (repo=${REPO_URL} ref=${REF})"
	install_chezmoi
	init_or_update
	chezmoi init
	info "chezmoi configuration regenerated"
	info "done. machine config was applied by chezmoi scripts (if any)."
	info "new shell: exec \"\$SHELL\" -l"
}

main "$@"
