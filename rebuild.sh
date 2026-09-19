#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_LINK="${HOME}/.dotfiles"

if [[ -e "$DOTFILES_LINK" && ! -L "$DOTFILES_LINK" ]]; then
  echo "error: $DOTFILES_LINK exists and is not a symlink; refusing to replace it" >&2
  exit 1
fi

DARWIN_REBUILD="$(command -v darwin-rebuild || true)"
if [[ -z "$DARWIN_REBUILD" ]]; then
  echo "error: darwin-rebuild is not installed; run ./bootstrap.sh first" >&2
  exit 1
fi

ln -sfn "$DIR" "$DOTFILES_LINK"
"$DIR/migrate-herdr.sh"
exec sudo "$DARWIN_REBUILD" switch --flake "${DOTFILES_LINK}#mac"
