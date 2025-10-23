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

      # Shared home-manager configuration for macOS
      darwinHomeManagerConfig = { pkgs, config, lib, ... }: {
        imports = [
          ./home
          ./home/darwin
        ];
      };

      # Shared Linux system packages
      linuxSystemPackages = pkgs: with pkgs; [
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
      ];

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
              users.${username} = darwinHomeManagerConfig;
            };
          }
        ];
      };

      # Home Manager configurations for Linux
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgsFor.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./home
          ./home/linux
          {
            home.username = username;
            home.homeDirectory = "/home/${username}";
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };

      homeConfigurations."${username}-aarch64" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgsFor.aarch64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./home
          ./home/linux
          {
            home.username = username;
            home.homeDirectory = "/home/${username}";
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };

      # Linux system configurations with system-manager
      systemConfigs."illusion" = system-manager.lib.makeSystemConfig {
        modules = [
          ./linux
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.hostPlatform = "x86_64-linux";
          }
          {
            system-manager.allowAnyDistro = true;
            users.mutableUsers = true;
          }
          ({ config, lib, pkgs, ... }: {
            environment.systemPackages = linuxSystemPackages pkgs;
          })
        ];
      };

      systemConfigs."illusion-aarch64" = system-manager.lib.makeSystemConfig {
        modules = [
          ./linux
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.hostPlatform = "aarch64-linux";
          }
          {
            system-manager.allowAnyDistro = true;
            users.mutableUsers = true;
          }
          ({ config, lib, pkgs, ... }: {
            environment.systemPackages = linuxSystemPackages pkgs;
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
