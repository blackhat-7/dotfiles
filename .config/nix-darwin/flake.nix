# ~/.config/nix-darwin/flake.nix
{
  description = "My Nix-Darwin Flake Configuration";

  inputs = {
    # The source for all packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # The tool that manages macOS
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Optional but highly recommended: Home Manager for user-level config
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs: {
    # This is the main output that Nix-Darwin will build.
    darwinConfigurations."illusion" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";

      # Special arguments passed to your configuration
      specialArgs = { inherit inputs; };

      # The list of modules to import.
      # Your main configuration file will be `./darwin-configuration.nix`
      # We also include the home-manager module.
      modules = [
        ./darwin-configuration.nix
        home-manager.darwinModules.home-manager
      ];
    };
  };
}
