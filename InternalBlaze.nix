{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    pkgs.vim
    pkgs.coreutils-full
  ];

  nix.settings.experimental-features = "nix-command flakes";
  nix.channel.enable = false;

  programs.bash = {
    enable = true;
    completion.enable = true;
  };

  system.primaryUser = "akifumi";

  system.configurationRevision = with inputs; (self.rev or self.dirtyRev or null);

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 7;

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.akifumi.home = "/Users/akifumi";

  security.pam.services.sudo_local = {
    reattach = true;
    touchIdAuth = true;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    casks = [
      "qutebrowser"
      "j"
      "docker-desktop"
      "amethyst"
      "inkscape"
      "bitwarden" # workaround for old electron
    ];
  };
}
