{ user, hostPlatform, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = hostPlatform;

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;

  # Touch ID for sudo (writes /etc/pam.d/sudo_local, which survives macOS updates).
  security.pam.services.sudo_local.touchIdAuth = true;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew.autoMigrate = true;
  nix-homebrew = {
    enable = true;
    inherit user;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = false;
    onActivation.extraFlags = [ "--verbose" ];
    brews = [
      # Automic Vault's hardened gh; installed by `av harden gh`, declared here
      # so the zap cleanup above doesn't uninstall it on every rebuild.
      "automic-vault/isotopes/gh-cli"
      "herdr"
      "pi-coding-agent"
      "uv"
    ];
    casks = [
      "raycast"
      "alt-tab"
      "claude-code@latest"
      "codex"
      "docker-desktop"
      "hiddenbar"
      "maccy"
      "opensuperwhisper"
      "rectangle"
      "wezterm"
      "automic-vault/isotopes/automic-vault"
    ];
  };
}
