# Nix Flake for macOS (nix-darwin) and Linux (system-manager)
{
  description = "Cross-platform Nix configuration";

  inputs = {
    # The source for all packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # The tool that manages macOS
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager for user-level config
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System-manager for Linux
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Additional inputs
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, system-manager, neovim-nightly-overlay, nix-index-database, ... }@inputs:
    let
      # System types to support
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for each supported system
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      });

      # Local overlays
      localOverlays = import ./overlays { inherit (nixpkgs) lib; };

      # Username
      username = "illusion";

      # Shared home-manager configuration
      homeManagerConfig = { pkgs, config, lib, ... }: {
        imports = [ ./home ];
      };

    in {
      # macOS configurations
      darwinConfigurations."illusion" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs localOverlays; };
        modules = [
          { nixpkgs.config.allowUnfree = true; }
          ./darwin
          ./homebrew
          home-manager.darwinModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.${username} = homeManagerConfig;
            };
          }
        ];
      };

      # Linux configurations using system-manager
      systemConfigs."illusionPC" = system-manager.lib.makeSystemConfig {
          modules = [
            ./linux
            { nixpkgs.config.allowUnfree = true; }
            # Allow system-manager to run on any Linux distribution
            {
              system-manager.allowAnyDistro = true;
              # Make user management less intrusive
              users.mutableUsers = true;
            }
            ({ config, lib, pkgs, ... }: {
              # Basic system configuration
              nixpkgs.hostPlatform = "x86_64-linux";

              # Instead of replacing /etc/passwd and /etc/group, just ensure
              # needed packages are installed for the user
              environment.etc."profile.d/user-shell.sh".text = ''
                # Set default shell if desired
                # To actually change your shell, use: chsh -s ${pkgs.fish}/bin/fish
                export DEFAULT_SHELL="${pkgs.fish}/bin/fish"
              '';

              # System packages
              environment.systemPackages = with pkgs; [
                # Basic tools
                vim
                htop
                git
                curl
                wget
                fish
                zsh
                tmux

                # Development
                go
                python3

                # Networking
                tailscale

                # Add more packages as needed
              ];
            })
          ];
        };

      # Development shells
      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          packages = with nixpkgsFor.${system}; [ nixfmt-tree ];
        };
      });
    };
}
