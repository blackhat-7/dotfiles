{
  description = "Linux Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, system-manager, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });

      username = "illusion";

      # Upstream's cargo check runs `nix eval`, which tries to write to
      # $HOME/.cache/nix. The Nix sandbox sets HOME=/homeless-shelter
      # (unwritable), so patch the source to redirect HOME to $TMPDIR.
      # Remove once upstream sets HOME in its own preCheck.
      patchedSystemManagerSrc = nixpkgsFor.x86_64-linux.applyPatches {
        name = "system-manager-src-patched";
        src = system-manager;
        postPatch = ''
          substituteInPlace package.nix \
            --replace-fail \
              'export NIX_STATE_DIR=$TMPDIR' \
              'export NIX_STATE_DIR=$TMPDIR
              export HOME=$TMPDIR'
        '';
      };

      patchedSystemManagerLib = import "${patchedSystemManagerSrc}/nix/lib.nix" {
        inherit nixpkgs;
        userborn = system-manager.inputs.userborn;
      };
    in {
      # Home Manager configuration for Linux
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgsFor.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./home
          {
            home.username = username;
            home.homeDirectory = "/home/${username}";
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };

      # System configuration with system-manager (patched source)
      systemConfigs.illusionPC = patchedSystemManagerLib.makeSystemConfig {
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

      packages.x86_64-linux.system-manager =
        nixpkgsFor.x86_64-linux.callPackage "${patchedSystemManagerSrc}/nix/packages/wrapper.nix" {
          system-manager-unwrapped =
            nixpkgsFor.x86_64-linux.callPackage "${patchedSystemManagerSrc}/package.nix" { };
        };

      # Development shells
      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          packages = with nixpkgsFor.${system}; [ nixfmt ];
        };
      });
    };
}
