{ config, pkgs, lib, ... }:

{
  nixpkgs.hostPlatform = "x86_64-linux";
  
  # Disable systemd userborn service
  systemd.services.userborn.enable = false;

  # System packages
  environment.systemPackages = with pkgs; [
    curl
    wget
    vim
    git
    htop
    tmux
    fish
    zsh
    openssh
  ];

  # Shell configuration - CRITICAL: Keep existing system shells to prevent lockout
  environment.etc."shells" = {
    enable = true;
    text = ''
      /usr/bin/bash
      /bin/bash
      /run/system-manager/sw/bin/bash
      /bin/sh
      /usr/bin/git-shell
      /usr/bin/fish
      /bin/fish
      /usr/bin/systemd-home-fallback-shell
      /bin/rbash
      /usr/bin/rbash
      /usr/bin/sh
      ${pkgs.fish}/bin/fish
      ${pkgs.zsh}/bin/zsh
    '';
  };

  # Environment variables
  environment.etc."environment" = {
    enable = true;
    text = ''
      LANG=en_US.UTF-8
      LC_ALL=en_US.UTF-8
      TZ=Asia/Kolkata
    '';
  };

  # Nix settings
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  # System services
  systemd.services = {
    openssh = {
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
    
    wakeOnLan = {
      enable = true;
      description = "Wake on lan";
      requires = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.ethtool}/bin/ethtool -s enp5s0 wol g";
        Type = "oneshot";
      };
    };

    ramRgbOff = {
      enable = true;
      description = "Turn off RAM RGB lighting";
      after = [ "systemd-modules-load.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "ram-rgb-off";
          runtimeInputs = [ pkgs.openrgb pkgs.gawk ];
          text = ''
            # Set every DRAM device OpenRGB finds to black; other RGB devices stay as they are.
            mapfile -t ids < <(openrgb --list-devices |
              awk '/^[0-9]+: /{i=$1+0} /Type:[[:space:]]+DRAM/{print i}')
            if [ ''${#ids[@]} -eq 0 ]; then echo "No RAM RGB device found" >&2; exit 1; fi
            args=()
            for id in "''${ids[@]}"; do args+=(-d "$id" -m direct -c 000000); done
            openrgb "''${args[@]}"
          '';
        });
        Type = "oneshot";
      };
    };
  };

  # SSH configuration
  environment.etc."ssh/sshd_config.d/99-system-manager.conf" = {
    enable = true;
    text = ''
      PermitRootLogin no
      PasswordAuthentication no
      ChallengeResponseAuthentication no
      UsePAM yes
      PrintMotd no
      AcceptEnv LANG LC_*
      Subsystem sftp ${pkgs.openssh}/libexec/sftp-server
    '';
  };

  # sudo approval from the phone when an AI agent runs sudo (scripts/sudo-approve). Root-owned and
  # read-only, with a fixed PATH since it runs as root. ./install adds the PAM lines that call it.
  environment.etc."sudo-approve".source = pkgs.writeShellScript "sudo-approve" ''
    export PATH=${lib.makeBinPath (with pkgs; [ coreutils curl jq procps ])}
    ${builtins.readFile ../../scripts/sudo-approve/sudo-approve}
  '';
}
