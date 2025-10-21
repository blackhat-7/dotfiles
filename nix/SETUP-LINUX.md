# Setting Up Your Nix Configuration on Linux with System Manager

This guide will walk you through setting up your Nix configuration on a Linux system using [system-manager](https://github.com/numtide/system-manager). This setup allows you to share most of your configuration between macOS and Linux.

## Prerequisites

1. **Nix Package Manager**: You need to have Nix installed on your Linux system.
   ```bash
   # Install Nix using the official installer
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

2. **Git Repository**: Clone your dotfiles repository:
   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles/nix
   ```

## Configuration Structure

The flake-based configuration is organized to support both macOS (via nix-darwin) and Linux (via system-manager):

```
nix/
├── darwin/       # macOS-specific configuration
├── home/         # Home-manager configuration (shared + platform-specific)
│   ├── darwin/   # macOS-specific home configs
│   ├── linux/    # Linux-specific home configs
│   └── programs/ # Shared program configurations
├── linux/        # Linux-specific system configuration
├── overlays/     # Nixpkgs overlays (platform-specific)
├── flake.nix     # Main entry point
├── setup.sh      # Script to apply the configuration
└── rollback.sh   # Script to rollback to previous configuration
```

## System Setup

### First-time Setup

Run the setup script from the `nix` directory:

```bash
cd ~/dotfiles/nix
chmod +x ./setup.sh
./setup.sh
```

This script will:

1. Use `system-manager` to detect your hostname and find the matching configuration
2. Build and activate the system configuration
3. Configure system services, packages, and environment settings

You'll need to provide your sudo password when prompted.

### What Gets Configured

The Linux configuration sets up:

1. **System Packages**: Installs common utilities and tools
2. **Shell Configuration**: Adds shells like Fish and ZSH
3. **Environment Variables**: Sets locale, timezone, and other environment settings
4. **SSH Server**: Configures OpenSSH with secure defaults
5. **System Services**: Sets up and starts required services

### Rollback If Needed

If something goes wrong, you can roll back to the previous configuration:

```bash
cd ~/dotfiles/nix
./rollback.sh
```

## Important Notes

1. **Not NixOS**: System-manager is a lightweight tool for managing non-NixOS systems. It has a more limited set of options compared to NixOS or nix-darwin.

2. **File Conflicts**: The first time you run the setup, you might see warnings about existing files. This is normal, as system-manager needs to manage these files.

3. **Supported Distributions**: System-manager officially supports Ubuntu and NixOS, but can be used on other distributions with the `system-manager.allowAnyDistro` option (which is enabled in our configuration).

4. **Available Options**: System-manager mainly supports:
   - Managing files under `/etc/`
   - Managing systemd services
   - Installing packages

5. **Home Manager**: For user-level configuration, we use home-manager which is more consistent across platforms.

## Adding Custom Configuration

### System-level Configuration

To add or modify system-level settings, edit the files in the `nix/linux/` directory.

### User-level Configuration

To customize your user environment, edit the files in the `nix/home/` directory:
- Platform-independent configs: `nix/home/programs/`
- Linux-specific configs: `nix/home/linux/`

## Updating Your Configuration

After making changes to your configuration:

1. Make sure your changes are saved
2. Run `./setup.sh` again to apply the changes

The system will build the new configuration and apply it.

## Troubleshooting

### Common Issues

1. **Permission Denied**: Make sure you have sudo privileges on your system.

2. **Unmanaged Path Exists**: For files that system-manager can't manage due to conflicts:
   - Check the error message to identify the file
   - If it's safe to do so, move the original file aside: `sudo mv /etc/file.conf /etc/file.conf.backup`
   - Run `./setup.sh` again

3. **Configuration Errors**: If you see errors about undefined options or invalid values:
   - System-manager supports fewer options than NixOS
   - Check the error message to identify the problematic option
   - Remove or replace it with a compatible alternative