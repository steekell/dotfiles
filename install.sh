#!/bin/sh
# Start chezmoi only — does NOT configure the machine.
# Machine setup lives in .chezmoiscripts/ (run via chezmoi apply).
#
# Idempotent. Override: DOTFILES_REPO, DOTFILES_REF, CHEZMOI_BIN_DIR
#
#   curl -fsSL https://raw.githubusercontent.com/steekell/dotfiles/v0.1.0/install.sh | sh
#   DOTFILES_REF=main curl -fsSL .../install.sh | sh
set -eu

REPO_URL="${DOTFILES_REPO:-https://github.com/steekell/dotfiles.git}"
# Pin to this release by default (override: DOTFILES_REF=main).
DEFAULT_REF="v0.1.0"
REF="${DOTFILES_REF:-$DEFAULT_REF}"
BIN_DIR="${CHEZMOI_BIN_DIR:-$HOME/.local/bin}"
export PATH="${BIN_DIR}:${PATH}"

info() { printf '%s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

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
		if command -v git >/dev/null 2>&1; then
			git -C "$sp" remote get-url origin >/dev/null 2>&1 || \
				git -C "$sp" remote add origin "$REPO_URL" 2>/dev/null || true
			git -C "$sp" fetch --tags origin 2>/dev/null || git -C "$sp" fetch origin || true
			if git -C "$sp" rev-parse --verify "refs/tags/${REF}" >/dev/null 2>&1; then
				git -C "$sp" checkout -q "tags/${REF}" || true
			elif git -C "$sp" rev-parse --verify "refs/remotes/origin/${REF}" >/dev/null 2>&1; then
				git -C "$sp" checkout -q -B "$REF" "origin/${REF}" || true
			elif git -C "$sp" rev-parse --verify "refs/heads/${REF}" >/dev/null 2>&1; then
				git -C "$sp" checkout -q "$REF" || true
			else
				info "warning: ref '${REF}' not found locally after fetch; applying current source"
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
	info "dotfiles install — start chezmoi only (repo=${REPO_URL} ref=${REF})"
	install_chezmoi
	init_or_update
	info "done. machine config was applied by chezmoi scripts (if any)."
	info "new shell: exec \"\$SHELL\" -l"
}

main "$@"
