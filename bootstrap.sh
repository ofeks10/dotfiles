#!/usr/bin/env bash
# Takes a fresh Mac from nothing to a built nix-darwin config.
# Run this once. After it finishes, use ./rebuild.sh for every later change.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_LINK="${HOME}/.dotfiles"

cd "$DIR"

if ! command -v sudo >/dev/null 2>&1; then
  echo "error: sudo is required to bootstrap nix-darwin" >&2
  exit 1
fi

if [[ -e "$DOTFILES_LINK" && ! -L "$DOTFILES_LINK" ]]; then
  echo "error: $DOTFILES_LINK exists and is not a symlink; refusing to replace it" >&2
  exit 1
fi

echo "==> Step 1: Determinate Nix"
if command -v nix >/dev/null 2>&1; then
  echo "    nix already installed, skipping"
else
  if ! command -v curl >/dev/null 2>&1; then
    echo "error: curl is required to install Nix" >&2
    exit 1
  fi
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: symlink this repo to ~/.dotfiles"
# home.nix resolves its mkOutOfStoreSymlink paths through ~/.dotfiles, so this
# has to exist before the first switch or the build will fail to find them.
ln -sfn "$DIR" "$DOTFILES_LINK"

"$DIR/migrate-herdr.sh"

echo "==> Step 3: first darwin-rebuild switch (pinned by flake.lock)"
# darwin-rebuild doesn't exist yet on a fresh machine, so run it straight
# from the flake this once. After this, rebuild.sh works normally.
# Resolve the exact nix-darwin revision already pinned by flake.lock. This keeps
# the one-time bootstrap aligned with the system configuration it is about to
# evaluate, rather than fetching a moving release branch.
# sudo resets PATH to a secure default that excludes /nix/.../bin, so a
# freshly installed nix would not be found under sudo even though it is
# on PATH here. Resolve the absolute path first and invoke that instead.
NIX_BIN="$(command -v nix)"
NIX_DARWIN_REV="$("$NIX_BIN" eval --raw --impure --expr \
  '(builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nix-darwin.locked.rev')"
if [[ -z "$NIX_DARWIN_REV" ]]; then
  echo "error: could not read nix-darwin revision from flake.lock" >&2
  exit 1
fi
# "mac" is the flake host label - if you renamed it, change it in flake.nix
# and rebuild.sh too.
sudo "$NIX_BIN" run "github:nix-darwin/nix-darwin/${NIX_DARWIN_REV}#darwin-rebuild" -- \
  switch --flake "${DOTFILES_LINK}#mac"
# If this still fails with "nix: command not found", open a new terminal
# (Determinate adds nix to new shells' PATH) and re-run ./bootstrap.sh.

echo "==> Done. Use ./rebuild.sh for future changes."
