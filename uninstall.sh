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

  (default)       Remove managed config files, now-empty directories they
                  created, and packages installed by setup (packages.manifest).
                  Keeps chezmoi binary, source dir, and user data.
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

run_root() {
	if [ "$(id -u)" -eq 0 ]; then
		"$@"
	elif command -v sudo >/dev/null 2>&1; then
		sudo "$@"
	else
		warn "need root for: $*"
		return 1
	fi
}

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

	files=$(chezmoi managed --include=files,symlinks 2>/dev/null || true)
	if [ -n "$files" ]; then
		printf '%s\n' "$files" | while IFS= read -r rel || [ -n "$rel" ]; do
			[ -z "$rel" ] && continue
			case "$rel" in
				/*) target="$rel" ;;
				*) target="${HOME}/${rel}" ;;
			esac
			if [ -L "$target" ] || [ -f "$target" ]; then
				rm -f "$target" && info "  removed $target" || warn "could not remove $target"
			fi
		done
	else
		info "no managed files/symlinks reported"
	fi

	# Directories chezmoi created for those files/symlinks. Never rm -rf: only
	# rmdir once empty, deepest first, so leftover unmanaged content is kept.
	dirs=$(chezmoi managed --include=dirs 2>/dev/null || true)
	[ -n "$dirs" ] || return 0
	printf '%s\n' "$dirs" | awk '{ n = gsub(/\//, "/"); print n, $0 }' |
		sort -rn -k1,1 | cut -d' ' -f2- |
		while IFS= read -r rel || [ -n "$rel" ]; do
			[ -z "$rel" ] && continue
			case "$rel" in
				/*) target="$rel" ;;
				*) target="${HOME}/${rel}" ;;
			esac
			[ -d "$target" ] || continue
			rmdir "$target" 2>/dev/null && info "  removed empty dir $target" || warn "kept non-empty dir $target (contains unmanaged files)"
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

# Manifest lines written by run_onchange_before_10-packages.sh.tmpl:
#   <pm>:<suffix>[:<pkg>]   (older entries lack the <pkg> field; suffix is used instead)
remove_packages_installed_by_setup() {
	manifest="${STATE_DIR}/packages.manifest"
	[ -f "$manifest" ] || return 0

	info "removing packages installed by setup..."
	tmp_dir=$(mktemp -d)

	while IFS= read -r line || [ -n "$line" ]; do
		case "$line" in
			'' | '#'*) continue ;;
		esac
		pm=${line%%:*}
		rest=${line#*:}
		suffix=${rest%%:*}
		if [ "$rest" != "$suffix" ]; then
			pkg=${rest#*:}
		else
			pkg=""
		fi
		[ -z "$pkg" ] && pkg="$suffix"
		printf '%s\n' "$pkg" >>"${tmp_dir}/${pm}"
	done <"$manifest"

	for f in "${tmp_dir}"/*; do
		[ -e "$f" ] || continue
		pm=$(basename "$f")
		pkgs=$(sort -u "$f" | tr '\n' ' ')
		[ -n "${pkgs% }" ] || continue
		# shellcheck disable=SC2086
		case "$pm" in
			brew) brew uninstall $pkgs || warn "brew uninstall failed for: $pkgs" ;;
			brew-cask) brew uninstall --cask $pkgs || warn "brew uninstall --cask failed for: $pkgs" ;;
			apt) run_root apt-get remove -y $pkgs || warn "apt-get remove failed for: $pkgs" ;;
			dnf) run_root dnf remove -y $pkgs || warn "dnf remove failed for: $pkgs" ;;
			pacman | yay | aur) run_root pacman -Rns --noconfirm $pkgs || warn "pacman -Rns failed for: $pkgs" ;;
			zypper) run_root zypper --non-interactive remove $pkgs || warn "zypper remove failed for: $pkgs" ;;
			apk) run_root apk del $pkgs || warn "apk del failed for: $pkgs" ;;
			pkg) run_root pkg delete -y $pkgs || warn "pkg delete failed for: $pkgs" ;;
			*) warn "unknown package manager '${pm}' in manifest — remove manually: $pkgs" ;;
		esac
	done

	rm -rf "$tmp_dir"
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
