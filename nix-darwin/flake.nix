# ~/.config/nix-darwin/flake.nix
{
  description = "My Nix-Darwin Flake Configuration";

  inputs = {
    # The source for all packages
    nixpkgs.url = "github:NixOS/nixpkgs/32f313e49e42f715491e1ea7b306a87c16fe0388";

    # The tool that manages macOS
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Optional but highly recommended: Home Manager for user-level config
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      neovim-nightly-overlay,
      nix-index-database,
      ...
    }@inputs:
    # This is the main output that Nix-Darwin will build.
    let
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        config = { allowUnfree = true; };
      };
      localOverlays = import ./overlays { inherit (nixpkgs) lib; };
    in
    {
      darwinConfigurations."illusion" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";

        # Special arguments passed to your configuration
        specialArgs = { inherit inputs localOverlays; };

        modules = [
          { nixpkgs.config.allowUnfree = true; }
          ./darwin
          ./homebrew
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
      devShells.aarch64-darwin = {
        default = pkgs.mkShell { packages = with pkgs; [ nixfmt-tree ]; };
      };
    };
}
