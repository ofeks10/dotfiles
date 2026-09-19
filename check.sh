#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
cd "$ROOT"

echo "==> checking shell syntax"
bash -n bootstrap.sh rebuild.sh migrate-herdr.sh check.sh
if command -v zsh >/dev/null 2>&1; then
  zsh -n home/.fzf.zsh home/.p10k.zsh
else
  echo "    zsh not installed; skipped Zsh checks"
fi

echo "==> checking structured config"
jq empty home/.claude/settings.json
jq empty home/.config/nvim/lazy-lock.json
jq empty flake.lock

echo "==> checking managed source files"
for path in \
  home/.config/AGENTS.md \
  home/.config/herdr/config.toml \
  home/.config/nvim \
  home/.config/wezterm \
  home/.claude/settings.json \
  home/.gitconfig \
  home/.gitignore \
  home/.p10k.zsh \
  home/.fzf.zsh
do
  if [[ ! -e "$path" ]]; then
    echo "error: missing managed source: $path" >&2
    exit 1
  fi
done

echo "==> checking whitespace"
git diff --check

if command -v nix >/dev/null 2>&1; then
  echo "==> evaluating flake"
  nix flake check --no-build
else
  echo "    nix not installed; skipped flake evaluation"
fi

echo "checks passed"
