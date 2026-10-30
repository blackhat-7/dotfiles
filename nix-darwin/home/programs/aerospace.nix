{ pkgs, ... }:
{
  programs.aerospace = {
    enable = true;
    settings =
      let
        sticky-pip-script = pkgs.writeShellScriptBin "sticky-pip" ''
          current_workspace=$(${pkgs.aerospace}/bin/aerospace list-workspaces --focused)
          ${pkgs.aerospace}/bin/aerospace list-windows --all | awk -F' *\\| *' '$3 ~ /Picture[- ]in[- ]Picture/ { print $1 }' | while read window_id; do
            [ -n "$window_id" ] && ${pkgs.aerospace}/bin/aerospace move-node-to-workspace --window-id "$window_id" "$current_workspace"
          done
        '';
        # Reads the selected text aloud; pressed again while reading, stops.
        # Copying the selection replaces the clipboard.
        speak-selection = pkgs.writeShellScript "speak-selection" ''
          /usr/bin/pkill -x afplay && exit
          /usr/bin/osascript -e 'tell application "System Events" to keystroke "c" using command down'
          sleep 0.2
          /usr/bin/pbpaste | ${pkgs.callPackage ../../../pkgs/read-aloud.nix { }}/bin/read-aloud
        '';
      in
      pkgs.lib.recursiveUpdate ({
        on-window-detected = [
          {
            "if" = {
              app-name-regex-substring = "Zen";
              window-title-regex-substring = "Picture-in-Picture";
            };
            run = "layout floating";
          }
        ];
        exec-on-workspace-change = [
          "/bin/bash"
          "-c"
          "${sticky-pip-script}/bin/sticky-pip"
        ];
        workspace-to-monitor-force-assignment = {
          "1" = "main";
          "2" = "main";
          "3" = "main";
          "4" = "main";
          "5" = "main";
          "6" = "main";
          "7" = "main";
          "8" = "main";
          "9" = "main";
          "0" = "secondary";
        };
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
      }
      // builtins.fromTOML ''
            [mode.main.binding]
            cmd-slash = 'layout tiles horizontal vertical'
            cmd-comma = 'layout accordion horizontal vertical'

            cmd-j = 'focus down'
            cmd-k = 'focus up'

            cmd-shift-h = 'move left'
            cmd-shift-j = 'move down'
            cmd-shift-k = 'move up'
            cmd-shift-l = 'move right'

            alt-minus = 'resize smart -50'
            alt-equal = 'resize smart +50'

            cmd-1 = 'workspace 1'
            cmd-2 = 'workspace 2'
            cmd-3 = 'workspace 3'
            cmd-4 = 'workspace 4'
            cmd-5 = 'workspace 5'
            cmd-6 = 'workspace 6'
            cmd-7 = 'workspace 7'
            cmd-8 = 'workspace 8'
            cmd-9 = 'workspace 9'
            cmd-0 = 'workspace 0'

            cmd-shift-1 = 'move-node-to-workspace 1'
            cmd-shift-2 = 'move-node-to-workspace 2'
            cmd-shift-3 = 'move-node-to-workspace 3'
            cmd-shift-4 = 'move-node-to-workspace 4'
            cmd-shift-5 = 'move-node-to-workspace 5'
            cmd-shift-6 = 'move-node-to-workspace 6'
            cmd-shift-7 = 'move-node-to-workspace 7'
            cmd-shift-8 = 'move-node-to-workspace 8'
            cmd-shift-9 = 'move-node-to-workspace 9'
            cmd-shift-0 = 'move-node-to-workspace 0'

            alt-shift-semicolon = 'mode service'

        [mode.service.binding]
            esc = ['reload-config', 'mode main']
            r = ['flatten-workspace-tree', 'mode main']
            f = ['layout floating tiling', 'mode main']
            backspace = ['close-all-windows-but-current', 'mode main']

            alt-shift-h = ['join-with left', 'mode main']
            alt-shift-j = ['join-with down', 'mode main']
            alt-shift-k = ['join-with up', 'mode main']
            alt-shift-l = ['join-with right', 'mode main']

            down = 'volume down'
            up = 'volume up'
            shift-down = ['volume set 0', 'mode main']
      '')
      # fromTOML can't refer to store paths, so this binding is merged in here.
      { mode.main.binding.alt-esc = "exec-and-forget ${speak-selection}"; };
  };
}
