{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # CLI utilities
    bat
    docker
    docker-compose
    eza
    fd
    fzf
    gh
    jq
    lazygit
    neovim
    nodejs
    pnpm
    ripgrep
    zoxide

    # Fonts
    nerd-fonts.hack
  ];

  fonts.fontconfig.enable = true;
# Global environment variables
  home.sessionVariables = {
    EDITOR = "nvim";

    # `pnpm setup` can't run here: it self-installs into the read-only store.
    PNPM_HOME = "${config.home.homeDirectory}/Library/pnpm";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/Library/pnpm/bin"
  ];

  # Shell aliases (works across shells managed by Home Manager)
  home.shellAliases = {
    # File listing & navigation
    ls = "eza --color=auto ";
    # --classify needs an explicit `=value` (not bare `-F`) — eza's zsh
    # completion script treats a bare -F/--classify as requiring the next
    # word as its argument, which swallows folder-name tab-completion.
    ll = "eza -al --classify=auto ";
    la = "eza -A";
    l = "eza -C --classify=auto";
    ".." = "cd ..";
    cat = "bat ";

    # Shortcuts
    a = "code .";
    c = "code .";
    tmux = "tmux -2 -u";

    # Web development
    ns = "npm start";
    start = "npm start";
    nr = "npm run";
    run = "npm run";
    nis = "npm i -S";

    vim = "nvim";

    doup = "brew update && brew upgrade && brew autoremove && brew cleanup";

    python = "python3";
    pip = "pip3";
  };

  # Zoxide integration. enableZshIntegration is off on purpose: home-manager
  # sources that eval before the p10k/fzf-tab plugins, so zoxide's precmd
  # hook ends up ahead of theirs instead of last, which trips zoxide's own
  # "detected a possible configuration issue" doctor check on every shell
  # start. We eval it ourselves at the very end of initExtra instead, after
  # everything else that registers a precmd hook.
  programs.zoxide = {
    enable = true;
    enableZshIntegration = false;
    options = [ "--cmd cd" ];
  };

  # FZF integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Zsh Configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Zsh History configuration
    history = {
      size = 10000;
      save = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
      expireDuplicatesFirst = true;
    };

    # Native Home Manager Zsh Plugins (replaces Zinit)
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    # Logic loaded near the very top of .zshrc
    initExtraFirst = ''
      # Powerlevel10k instant prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';

    # Custom functions, key bindings, and completion styling
    initExtra = ''
      # Cursor/VSCode theme fallback
      if [[ "$TERM_PROGRAM" == "vscode" ]]; then
        PROMPT='%n@%m:%~%# '
        RPROMPT=""
      else
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
      fi

      # Key bindings
      bindkey -e
      bindkey '^p' history-search-backward
      bindkey '^n' history-search-forward

      # Custom functions
      function mkcd() {
        mkdir -p "$1" && cd "$1"
      }

      # Completion styling & fzf-tab previews
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -la $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -la $realpath'

      # Must stay last: zoxide's precmd hook needs to be the last one
      # registered, or it prints a "detected a possible configuration
      # issue" warning on every shell start.
      eval "$(zoxide init zsh --cmd cd)"
    '';
  };
  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
    force = true;
  };
  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
    force = true;
  };
  home.file.".config/herdr" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
    force = true;
  };
  home.file.".claude/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";
    force = true;
  };

  home.file.".gitconfig" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.gitconfig";
    force = true;
  };
  home.file.".p10k.zsh" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.p10k.zsh";
    force = true;
  };
  home.file.".fzf.zsh" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.fzf.zsh";
    force = true;
  };

  home.file.".claude/CLAUDE.md" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
    force = true;
  };
  home.file.".codex/AGENTS.md" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
    force = true;
  };
}
