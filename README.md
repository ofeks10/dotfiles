# dotfiles

Personal macOS system configuration, managed declaratively with
[Nix](https://nixos.org), [nix-darwin](https://github.com/nix-darwin/nix-darwin)
and [Home Manager](https://github.com/nix-community/home-manager). One
`darwin-rebuild switch` sets up packages, Homebrew casks, macOS defaults,
shell config, and editor/tool dotfiles — all from this repo.

## What this repo does

- **`flake.nix`** — pins `nixpkgs`, `nix-darwin`, `home-manager` and
  `nix-homebrew` and wires them together into one `darwinConfigurations."mac"`
  system.
- **`configuration.nix`** — system-level config: macOS defaults (dark mode,
  fast key repeat, list-view Finder, tap-to-click, etc.), and Homebrew
  (managed via `nix-homebrew`) for casks/brews that aren't in nixpkgs
  (`wezterm`, `claude-code`, `rectangle`, `maccy`, `alt-tab`, `hiddenbar`,
  `herdr`).
- **`home.nix`** — user-level config via Home Manager: CLI packages
  (`bat`, `eza`, `fzf`, `ripgrep`, `zoxide`, `lazygit`, `neovim`, `gh`,
  `docker`, `pnpm`, `jq`, `fd`, a Nerd Font), Zsh (powerlevel10k prompt,
  fzf-tab, aliases, history, keybindings), and symlinks for dotfiles that
  live in this repo (see below).
- **`home/`** — the actual dotfiles/config files, symlinked into place by
  `home.nix` (edited in place here; changes take effect after a rebuild —
  no need to re-symlink):
  - `.config/wezterm/` — WezTerm terminal config
  - `.config/nvim/` — Neovim config (lazy.nvim)
  - `.config/herdr/` — `herdr` terminal multiplexer config (installed via
    Homebrew, see `configuration.nix`)
  - `.config/AGENTS.md` — shared agent instructions, symlinked to both
    `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`
  - `.claude/settings.json` — Claude Code settings (theme, status line)
  - `.gitconfig`, `.p10k.zsh`, `.fzf.zsh`

## Prerequisites

- A Mac (Apple Silicon by default — see [Intel Macs](#intel-macs) below).
- Admin/sudo access (nix-darwin and Homebrew both need it).
- An SSH key on GitHub if you want to `git clone` over SSH (or clone over
  HTTPS instead).

## Getting started (fresh Mac)

```sh
git clone git@github.com:ofeks10/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./bootstrap.sh
```

`bootstrap.sh` does everything needed on a brand-new machine:

1. Installs Nix via the [Determinate Systems installer](https://install.determinate.systems)
   (skipped if `nix` is already on `PATH`).
2. Symlinks this repo to `~/.dotfiles` — `home.nix` resolves its dotfile
   symlinks (wezterm, nvim, herdr, etc.) through that fixed path, so it has
   to exist before the first build.
3. Runs the first `darwin-rebuild switch`, pinned to the `nix-darwin-26.05`
   release (since `darwin-rebuild` doesn't exist yet on a fresh machine).
   The system config it applies is still pinned by this repo's `flake.lock`.

If it fails with `nix: command not found` right after install, open a new
terminal (so the daemon-installed `nix` is on `PATH`) and re-run
`./bootstrap.sh`.

After it finishes, everything below is set up: Homebrew + casks, CLI tools,
Zsh with powerlevel10k, and all the symlinked dotfiles.

## Day-to-day usage

After the first bootstrap, use `rebuild.sh` for every change:

```sh
./rebuild.sh
```

This re-symlinks the repo to `~/.dotfiles` (in case it moved) and runs
`sudo darwin-rebuild switch --flake ~/.dotfiles#mac`.

Typical workflow:

1. Edit files in this repo (`home.nix`, `configuration.nix`, or anything
   under `home/`).
2. Run `./rebuild.sh`.
3. Commit and push once you're happy with the change.

Things you can add/change:
- **CLI packages**: add to `home.packages` in `home.nix` (search
  [search.nixos.org](https://search.nixos.org/packages) for package names).
- **Casks/brews** (GUI apps, or anything not in nixpkgs): add to
  `homebrew.casks` / `homebrew.brews` in `configuration.nix`. Note
  `onActivation.cleanup = "zap"` — anything installed via Homebrew but not
  listed there gets removed on the next rebuild.
- **Shell aliases / zsh config**: `home.shellAliases` and
  `programs.zsh` in `home.nix`.
- **A new dotfile to manage**: put the real file under `home/`, then add a
  matching `home.file."<target-path>"` entry in `home.nix` using
  `config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/<path>"` — this
  keeps the file editable in place in the repo instead of copied into the
  Nix store.
- **macOS system defaults**: `system.defaults` in `configuration.nix`.

### Intel Macs

`configuration.nix` sets `nixpkgs.hostPlatform = "aarch64-darwin"` for
Apple Silicon. On an Intel Mac, change that to `x86_64-darwin` before
bootstrapping.

### Updating pinned inputs

`flake.lock` pins exact versions of `nixpkgs`, `nix-darwin`, `home-manager`
and `nix-homebrew`. To bump them:

```sh
nix flake update
./rebuild.sh
```

## Repo layout

```
.
├── bootstrap.sh        # one-time setup on a fresh Mac
├── rebuild.sh          # apply changes on every later run
├── flake.nix           # flake inputs + darwinConfigurations."mac"
├── flake.lock          # pinned input versions
├── configuration.nix   # system-level: macOS defaults, Homebrew
├── home.nix            # user-level: packages, shell, dotfile symlinks
└── home/                # actual dotfiles, symlinked into $HOME by home.nix
    ├── .claude/
    ├── .config/
    │   ├── AGENTS.md
    │   ├── nvim/
    │   ├── herdr/
    │   └── wezterm/
    ├── .fzf.zsh
    ├── .gitconfig
    └── .p10k.zsh
```
