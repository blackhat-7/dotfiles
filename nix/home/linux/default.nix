{ pkgs, lib, ... }:

{
  # Linux-specific packages
  home.packages = with pkgs; [
    firefox
    cowsay
    # Add other Linux-specific packages here
  ];

  # Enable the generic Linux target. Disable Home Manager's generic GPU
  # integration on ARM; it pulls x86-only Intel driver packages.
  targets.genericLinux = {
    enable = true;
    gpu.enable = false;
  };

  # Linux-specific configurations
  xdg = {
    enable = true;
    # Configure XDG directories if needed
  };

  # Optional: Configure systemd user services if needed
  systemd.user = {
    # Example of a systemd user service (uncomment and customize as needed)
    # services.example-service = {
    #   Unit = {
    #     Description = "Example User Service";
    #   };
    #   Service = {
    #     ExecStart = "${pkgs.hello}/bin/hello";
    #     Restart = "on-failure";
    #   };
    #   Install = {
    #     WantedBy = [ "default.target" ];
    #   };
    # };
  };
}
