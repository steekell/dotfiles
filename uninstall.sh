#!/bin/sh
# Uninstall steekell/dotfiles helpers — POSIX sh.
#
#   ./uninstall.sh                 # remove managed setup artefacts; keep chezmoi + user data
#   ./uninstall.sh --chezmoi-only  # remove chezmoi source/config/binary; leave $HOME targets
#   ./uninstall.sh --purge         # managed targets + chezmoi + artefacts
#
# Env: DOTFILES_YES=1 skips confirmation on --purge
set -eu

MODE="default" # default | chezmoi-only | purge

usage() {
	cat <<'EOF'
Usage: uninstall.sh [--chezmoi-only | --purge] [-y|--yes] [-h|--help]

  (default)       Remove managed targets and setup artefacts created by this
                  project. Keeps chezmoi binary, source dir, and user data.
  --chezmoi-only  Remove chezmoi source + config (+ binary if under ~/.local/bin).
                  Does NOT remove files already applied in $HOME.
  --purge         default cleanup + chezmoi-only (full teardown of this setup).

  -y, --yes       Skip confirmation for --purge
EOF
}

YES="${DOTFILES_YES:-0}"

while [ $# -gt 0 ]; do
	case "$1" in
		--chezmoi-only) MODE="chezmoi-only" ;;
		--purge) MODE="purge" ;;
		-y | --yes) YES=1 ;;
		-h | --help)
			usage
			exit 0
			;;
		*)
			printf 'error: unknown option: %s\n' "$1" >&2
			usage >&2
			exit 2
			;;
	esac
	shift
done

info() { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }

STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
CHEZMOI_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi"
CHEZMOI_SRC="${HOME}/.local/share/chezmoi"
CHEZMOI_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/chezmoi"
BIN_CANDIDATES="
${HOME}/.local/bin/chezmoi
"

has_chezmoi() { command -v chezmoi >/dev/null 2>&1; }

resolve_source() {
	if has_chezmoi; then
		sp=$(chezmoi source-path 2>/dev/null || true)
		if [ -n "${sp:-}" ]; then
			CHEZMOI_SRC="$sp"
		fi
	fi
}

# Track optional package removal later (bootstrap does not install pkgs in v0.1.0).
stop_services() {
	# Placeholder: stop user services created by future run_ scripts.
	:
}

remove_managed_targets() {
	if ! has_chezmoi; then
		warn "chezmoi not on PATH — skip managed target removal"
		return 0
	fi
	resolve_source
	info "removing chezmoi-managed targets..."
	# Files and symlinks only; do not wipe whole directories blindly.
	# --path-style=absolute needs recent chezmoi; fall back to relative.
	list=$(chezmoi managed --include=files,symlinks 2>/dev/null || true)
	if [ -z "$list" ]; then
		info "no managed files/symlinks reported"
		return 0
	fi
	printf '%s\n' "$list" | while IFS= read -r rel || [ -n "$rel" ]; do
		[ -z "$rel" ] && continue
		case "$rel" in
			/*) target="$rel" ;;
			*) target="${HOME}/${rel}" ;;
		esac
		if [ -L "$target" ] || [ -f "$target" ]; then
			rm -f "$target" && info "  removed $target" || warn "could not remove $target"
		elif [ -d "$target" ]; then
			# Only remove empty dirs that chezmoi managed as dirs — skip non-empty.
			rmdir "$target" 2>/dev/null && info "  removed empty dir $target" || true
		fi
	done
}

remove_artefacts() {
	info "removing setup artefacts..."
	if [ -d "$STATE_DIR" ]; then
		rm -rf "$STATE_DIR"
		info "  removed $STATE_DIR"
	fi
	# Future: remove service units / wrapper bins registered by bootstrap.
}

remove_packages_installed_by_setup() {
	# v0.1.0 bootstrap installs no packages. When it does, read a manifest
	# from $STATE_DIR and uninstall only those entries.
	if [ -f "${STATE_DIR}/packages.manifest" ]; then
		warn "packages.manifest present but automatic package removal is not implemented yet"
	fi
}

remove_chezmoi_only() {
	resolve_source
	info "removing chezmoi source/config/cache (targets in \$HOME left untouched)..."
	if [ -d "$CHEZMOI_SRC" ]; then
		rm -rf "$CHEZMOI_SRC"
		info "  removed $CHEZMOI_SRC"
	fi
	if [ -d "$CHEZMOI_CFG" ]; then
		rm -rf "$CHEZMOI_CFG"
		info "  removed $CHEZMOI_CFG"
	fi
	if [ -d "$CHEZMOI_CACHE" ]; then
		rm -rf "$CHEZMOI_CACHE"
		info "  removed $CHEZMOI_CACHE"
	fi
	# Binary only if it lives in our default user bin (don't touch Homebrew cellar).
	for b in $BIN_CANDIDATES; do
		if [ -f "$b" ] && [ -x "$b" ]; then
			rm -f "$b" && info "  removed $b" || true
		fi
	done
	# State dir is ours; remove on chezmoi-only too if present and empty of non-chezmoi meaning — yes it's ours.
	if [ -d "$STATE_DIR" ]; then
		rm -rf "$STATE_DIR"
		info "  removed $STATE_DIR"
	fi
}

confirm_purge() {
	if [ "$YES" = "1" ]; then
		return 0
	fi
	if [ ! -t 0 ]; then
		die_need_yes() {
			printf 'error: --purge needs confirmation on a TTY or -y / DOTFILES_YES=1\n' >&2
			exit 1
		}
		die_need_yes
	fi
	printf 'This will remove managed dotfiles AND chezmoi source/config. Continue? [y/N] '
	read -r ans || ans=
	case "$ans" in
		y | Y | yes | YES) ;;
		*)
			info "aborted"
			exit 1
			;;
	esac
}

case "$MODE" in
	default)
		info "uninstall (default): managed targets + artefacts; keep chezmoi"
		stop_services
		remove_packages_installed_by_setup
		remove_managed_targets
		remove_artefacts
		info "done. chezmoi binary and source kept (if present)."
		;;
	chezmoi-only)
		info "uninstall --chezmoi-only: source/config/binary; \$HOME targets kept"
		remove_chezmoi_only
		info "done. applied files in \$HOME were not removed."
		;;
	purge)
		confirm_purge
		info "uninstall --purge: full teardown"
		stop_services
		remove_packages_installed_by_setup
		remove_managed_targets
		remove_artefacts
		remove_chezmoi_only
		info "done."
		;;
esac
