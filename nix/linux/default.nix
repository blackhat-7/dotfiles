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

    # Strata + an agent's test suite hit 99 C at the stock 95/181 W; 75/125 W keeps long runs cooler.
    cpuPowerLimit = {
      enable = true;
      description = "Cap CPU package power (RAPL PL1 75 W, PL2 125 W)";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/sh -c 'echo 75000000 > /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw && echo 125000000 > /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw'";
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
}
