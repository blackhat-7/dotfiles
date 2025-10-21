{ pkgs, lib, ... }:

{
  # Only enable these configurations on Linux
  config = lib.mkIf pkgs.stdenv.isLinux {
    # Linux-specific packages
    home.packages = with pkgs; [
      firefox
      # Add other Linux-specific packages here
    ];

    # Enable the generic Linux target
    targets.genericLinux.enable = true;

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
  };
}
