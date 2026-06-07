{
  description = "nix-darwin configuration for InternalBlaze";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
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
      flake-parts,
      nix-darwin,
      nixpkgs,
      nixpkgsUnstable,
      home-manager,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ nix-darwin.flakeModules.default ];
      flake = {
        darwinConfigurations."InternalBlaze" = nix-darwin.lib.darwinSystem {
          modules = [
            ./InternalBlaze.nix
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
          specialArgs = { inherit inputs; };
        };
      };
    };
}
