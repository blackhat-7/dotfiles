# Cross-Platform Nix Configuration

This directory contains a Nix flake-based configuration that works across multiple platforms:

- **macOS**: Using nix-darwin + home-manager
- **Linux**: Using system-manager + home-manager

## Directory Structure

```
nix/
├── darwin/       # macOS-specific system configuration
├── home/         # Home-manager configuration (shared and platform-specific)
│   ├── darwin/   # macOS-specific home configs
│   ├── linux/    # Linux-specific home configs
│   └── programs/ # Shared program configurations
├── linux/        # Linux-specific system configuration
├── overlays/     # Nixpkgs overlays
├── flake.nix     # Main entry point
├── setup.sh      # Script to apply the configuration
└── rollback.sh   # Script to rollback to previous configuration
```

## Quick Start

### Setup on macOS or Linux

```bash
# Clone the repository
git clone <your-repo-url> ~/dotfiles

# Navigate to the nix directory
cd ~/dotfiles/nix

# Apply configuration (automatically detects your OS)
./setup.sh
# or directly with make
make switch
```

### Make sure Nix is installed first

```bash
# On macOS:
sh <(curl -L https://nixos.org/nix/install)

# On Linux:
sh <(curl -L https://nixos.org/nix/install) --daemon
```

For more detailed Linux setup instructions, see [SETUP-LINUX.md](SETUP-LINUX.md).

## Platform-specific Notes

### macOS (nix-darwin)

- Manages macOS system settings, Homebrew packages, and user configuration
- Configures various macOS settings via `defaults` commands
- Manages launchd services for background applications
- Integrates with Homebrew for packages not available in Nixpkgs

### Linux (system-manager)

- Manages system packages and services on non-NixOS Linux distributions
- Configures files in `/etc/` and systemd services
- Has a more limited scope than NixOS, focusing on basic system management
- Works alongside home-manager for user-level configuration

## Shared Configuration (home-manager)

Regardless of platform, home-manager manages user-level configuration:

- Shell configuration (Fish, Zsh, etc.)
- Development tools and editor settings
- Terminal configuration
- Git and other version control tools
- Various CLI utilities

## Updating

After making changes to your configuration:

1. Save your changes
2. Run `./setup.sh` or `make switch` to apply the changes

You can also use other make targets directly:
```bash
# Update flake inputs
make update

# Build macOS configuration specifically
make darwin

# Build Linux configuration specifically
make linux
```

## Rollback

If something goes wrong:

```bash
./rollback.sh
# or directly with make
make rollback
```

## Adding New Configuration

### System-level Changes

- For macOS: Add to files in `darwin/`
- For Linux: Add to files in `linux/`

### User-level Changes

- Cross-platform: Add to files in `home/programs/`
- macOS-specific: Add to files in `home/darwin/`
- Linux-specific: Add to files in `home/linux/`

## Helpful Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [nix-darwin Documentation](https://github.com/LnL7/nix-darwin)
- [system-manager Documentation](https://github.com/numtide/system-manager)

## Available Make Commands

The included Makefile provides various commands to manage your configuration:

```
make switch           # Auto-detect OS and apply configuration
make darwin           # Apply macOS configuration
make linux            # Apply Linux configuration
make rollback         # Roll back to previous working configuration
make update           # Update all flake inputs
make repair           # Verify and repair the Nix store
make index            # Build nix-index database
```