#!/usr/bin/env bash
# Reclaim common macOS/dev-machine disk space used by Nix and build caches.
# Default cleanup groups: Nix, uv/go/npm, Homebrew/Playwright/Spotify caches.
# Docker pruning is opt-in because it can delete useful volumes/images.

set -uo pipefail

YES=0
DRY_RUN=0
RUN_DOCKER=0
SKIP_NIX=0
FAILED=0

usage() {
  cat <<'EOF'
Usage: cleanup-space.sh [options]

Options:
  -y, --yes       Run default cleanup groups without prompting
  -n, --dry-run   Print commands without running them
      --docker    Also run docker system prune -a --volumes
      --skip-nix  Skip Nix garbage collection/optimise
  -h, --help      Show this help

Default groups:
  - nix-collect-garbage -d
  - sudo nix-collect-garbage -d
  - sudo nix-store --optimise
  - uv cache clean
  - go clean -cache -modcache -testcache
  - npm cache clean --force
  - brew cleanup -s
  - rm -rf ~/Library/Caches/ms-playwright
  - rm -rf ~/Library/Caches/com.spotify.client

Does not delete work repo artifacts (.venv, dist, output, node_modules) or personal data.
EOF
}

log() { printf '\n==> %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
has() { command -v "$1" >/dev/null 2>&1; }

run() {
  printf '+'
  printf ' %q' "$@"
  printf '\n'

  if (( DRY_RUN )); then
    return 0
  fi

  "$@"
  local status=$?
  if (( status != 0 )); then
    warn "command failed with status ${status}"
    FAILED=1
  fi
  return 0
}

confirm() {
  local prompt=$1
  if (( YES )); then
    return 0
  fi

  local reply
  read -r -p "${prompt} [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

show_disk() {
  log "$1"
  if has df; then
    df -h /
  fi
}

cleanup_nix() {
  if (( SKIP_NIX )); then
    log "Skipping Nix cleanup (--skip-nix)"
    return 0
  fi

  local nix_gc_cmd=""
  local nix_store_cmd=""
  nix_gc_cmd=$(command -v nix-collect-garbage 2>/dev/null || true)
  nix_store_cmd=$(command -v nix-store 2>/dev/null || true)

  if [[ -z "$nix_gc_cmd" && -z "$nix_store_cmd" ]]; then
    log "Skipping Nix cleanup (nix commands not found)"
    return 0
  fi

  if ! confirm "Run Nix garbage collection/optimise? This removes old rollback generations."; then
    log "Skipping Nix cleanup"
    return 0
  fi

  log "Nix cleanup"
  if [[ -n "$nix_gc_cmd" ]]; then
    run "$nix_gc_cmd" -d
    if has sudo; then
      run sudo "$nix_gc_cmd" -d
    fi
  fi

  if [[ -n "$nix_store_cmd" ]] && has sudo; then
    run sudo "$nix_store_cmd" --optimise
  fi
}

cleanup_dev_caches() {
  if ! confirm "Clean dev caches (uv/go/npm)?"; then
    log "Skipping dev caches"
    return 0
  fi

  log "Dev cache cleanup"
  if has uv; then
    run uv cache clean
  else
    warn "uv not found; skipping uv cache"
  fi

  if has go; then
    run go clean -cache -modcache -testcache
  else
    warn "go not found; skipping Go caches"
  fi

  if has npm; then
    run npm cache clean --force
  else
    warn "npm not found; skipping npm cache"
  fi
}

cleanup_library_caches() {
  if ! confirm "Clean app/library caches (Homebrew, Playwright, Spotify)?"; then
    log "Skipping app/library caches"
    return 0
  fi

  log "App/library cache cleanup"
  if has brew; then
    run brew cleanup -s
  else
    warn "brew not found; skipping Homebrew cleanup"
  fi

  local cache
  for cache in \
    "$HOME/Library/Caches/ms-playwright" \
    "$HOME/Library/Caches/com.spotify.client"
  do
    if [[ -e "$cache" ]]; then
      run rm -rf "$cache"
    else
      printf 'skip missing: %s\n' "$cache"
    fi
  done
}

cleanup_docker() {
  if (( ! RUN_DOCKER )); then
    log "Skipping Docker prune (pass --docker to enable)"
    return 0
  fi

  if ! has docker; then
    log "Skipping Docker prune (docker not found)"
    return 0
  fi

  log "Docker disk usage before prune"
  run docker system df

  if ! confirm "Prune unused Docker images, containers, networks, build cache, and volumes?"; then
    log "Skipping Docker prune"
    return 0
  fi

  log "Docker prune"
  run docker system prune -a --volumes -f
}

while (( $# > 0 )); do
  case "$1" in
    -y|--yes)
      YES=1
      ;;
    -n|--dry-run)
      DRY_RUN=1
      ;;
    --docker)
      RUN_DOCKER=1
      ;;
    --skip-nix)
      SKIP_NIX=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      warn "unknown option: $1"
      usage
      exit 2
      ;;
  esac
  shift
done

show_disk "Disk before cleanup"
cleanup_nix
cleanup_dev_caches
cleanup_library_caches
cleanup_docker
show_disk "Disk after cleanup"

if (( FAILED )); then
  warn "cleanup finished with one or more command failures"
  exit 1
fi

log "Done"
