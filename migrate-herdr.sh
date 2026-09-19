#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd -P)"
HERDR_HOME="$HOME/.config/herdr"
HERDR_SOURCE="$ROOT/home/.config/herdr"
HERDR_BACKUP="$HOME/.config/herdr.dotfiles-backup"

if [[ ! -L "$HERDR_HOME" ]]; then
  exit 0
fi

HERDR_REAL="$(cd "$HERDR_HOME" 2>/dev/null && pwd -P || true)"
if [[ "$HERDR_REAL" != "$HERDR_SOURCE" ]]; then
  exit 0
fi

if [[ -e "$HERDR_BACKUP" || -L "$HERDR_BACKUP" ]]; then
  echo "error: $HERDR_BACKUP already exists; refusing to migrate the old Herdr link" >&2
  exit 1
fi

mkdir -p "$HERDR_BACKUP"
for path in "$HERDR_REAL"/* "$HERDR_REAL"/.[!.]*; do
  [[ -e "$path" || -L "$path" ]] || continue
  [[ -f "$path" ]] || continue
  case "$path" in
    *.sock) continue ;;
  esac
  cp -p "$path" "$HERDR_BACKUP/"
done

rm "$HERDR_HOME"
mkdir -p "$HERDR_HOME"
echo "migrated legacy Herdr link to $HERDR_BACKUP"
