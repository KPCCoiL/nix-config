{
  description = "nix-darwin configuration for InternalBlaze";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    vis-tmux-repl = {
      url = "github:KPCCoiL/vis-tmux-repl/mac-sed";
      flake = false;
    };
    vis-lspc = {
      url = "gitlab:muhq/vis-lspc";
      flake = false;
    };
    base16-vis = {
      url = "github:przmv/base16-vis";
      flake = false;
    };

    bsm.url = "git+https://codeberg.org/CoiL/bsm.git";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nixpkgsUnstable,
      home-manager,
      ...
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.vim
            pkgs.coreutils-full
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";
          nix.channel.enable = false;

          # Enable alternative shell support in nix-darwin.
          programs.bash = {
            enable = true;
            completion.enable = true;
          };

          system.primaryUser = "akifumi";

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 7;

          # The platform the configuration will be used on.
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
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."InternalBlaze" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              inherit inputs;
              pkgsUnstable = import nixpkgsUnstable { system = "aarch64-darwin"; };
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.akifumi = ./home.nix;
          }
        ];
      };
    };
}
