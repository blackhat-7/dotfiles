{
  description = "Linux Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-gcloud.url = "github:NixOS/nixpkgs/6dedf69f94d03cbe7bdde106f2d4c23ae2a853bf";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    system-manager.url = "github:numtide/system-manager";

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      system-manager,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );

      gcloudPkgs = import inputs.nixpkgs-gcloud {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      username = "illusion";

    in
    {
      # Home Manager configuration for Linux
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgsFor.x86_64-linux;
        extraSpecialArgs = { inherit inputs gcloudPkgs; };
        modules = [
          ./home
          {
            home.username = username;
            home.homeDirectory = "/home/${username}";
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };

      # System configuration with system-manager
      systemConfigs.illusionPC = system-manager.lib.makeSystemConfig {
        modules = [
          ./linux
          {
            nixpkgs = {
              config.allowUnfree = true;
              hostPlatform = "x86_64-linux";
            };
            system-manager.allowAnyDistro = true;
            users.mutableUsers = true;
          }
        ];
      };

      packages.x86_64-linux = {
        system-manager = system-manager.packages.x86_64-linux.default;
        home-manager = home-manager.packages.x86_64-linux.home-manager;
      };

      # Development shells
      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          packages = with nixpkgsFor.${system}; [ nixfmt ];
        };
      });
    };
}
