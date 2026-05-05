# Linux system configuration with system-manager
{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    # Import any other Linux-specific modules here
  ];
  # Set host platform - will be determined by the system calling this config
  # nixpkgs.hostPlatform is set by the system-manager configuration

  # User configuration - only defining the minimum needed for home-manager
  users.users.illusion = {
    name = "illusion";
    home = "/home/illusion";
    shell = pkgs.fish;
    # Don't set isNormalUser, description, or groups as they already exist
  };

  # Environment configuration
  environment = {
    systemPackages = with pkgs; [
      # Basic tools
      curl
      wget
      vim
      git
      htop
      tmux

      # Shells - install to make available system-wide
      fish
      zsh

      # Other system utilities
      openssh
      tailscale
    ];

    # Add shells to /etc/shells
    etc."shells" = {
      enable = true;
      mode = "append";
      text = ''
        ${pkgs.fish}/bin/fish
        ${pkgs.zsh}/bin/zsh
      '';
    };

    # Set environment variables via /etc/environment
    etc."environment" = {
      enable = true;
      mode = "append";
      text = ''
        # Added by system-manager
        # LANG=en_US.UTF-8
        # LC_ALL=en_US.UTF-8
        # TZ=UTC
        # Add other environment variables here
      '';
    };
  };

  # Setup nix
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];

      # Nix 2.30+ defaults build-dir to /nix/var/nix/builds and rejects it
      # if any parent is world-writable or a symlink. Raspberry Pi installs can
      # trip that check, so use a root-owned path under /var/lib instead.
      build-dir = "/var/lib/nix-builds";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/nix-builds 0755 root root - -"
  ];

  # Configure OpenSSH via systemd service
  systemd.services.openssh = {
    enable = true;
    description = "OpenSSH server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.openssh}/bin/sshd -D -f /etc/ssh/sshd_config";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      KillMode = "process";
      Restart = "always";
    };
  };

  # OpenSSH configuration - use separate file to avoid conflicts
  environment.etc."ssh/sshd_config.d/99-system-manager.conf" = {
    enable = true;
    text = ''
      # Settings from system-manager
      PermitRootLogin yes
      PasswordAuthentication yes
      ChallengeResponseAuthentication no
      UsePAM yes
      PrintMotd no
      AcceptEnv LANG LC_*
      Subsystem sftp ${pkgs.openssh}/libexec/sftp-server
    '';
  };



  # Configure Tailscale service
  systemd.services.tailscaled = {
    enable = true;
    description = "Tailscale daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.tailscale}/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock";
      RuntimeDirectory = "tailscale";
      StateDirectory = "tailscale";
      Type = "notify";
      Restart = "on-failure";
    };
  };



}
