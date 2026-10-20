{ pkgs, lib, ... }:

let
  github =
    owner: repo: rev: hash:
    pkgs.fetchFromGitHub { inherit owner repo rev hash; };

  stevecastaneda = github "stevecastaneda" "paseo-plugins" "bea6aeabfdccc736c592104868d3789158a6263b" "sha256-8Z+exBYwY0R6InbAlPLuuCeSb+Dh+fIk0rpaVb7WPZQ=";
  cafe = github "paseo-cafe" "paseo-cafe" "6ad8ac037921e32dd2b72b127d9d9b4733a9fecf" "sha256-dH3IDCfcjMuBRsKyag7DypuwRWUPfeXOycZzKocBHAw=";

  # Plugins with npm dependencies. Paseo runs their manifest `build` steps only
  # for Git/npm installs, so Nix does that work here.
  beautiful-chat = pkgs.buildNpmPackage {
    pname = "paseo-beautiful-chat";
    version = "0.1.0";
    src = github "ABorakati" "beautiful-chat" "42b61d8301b5400a67821bbbfcf99fa8b681dc37" "sha256-5fqmWmKBgZGEVUiEy4mBA9IqhCvQSYacfaPVORDzp5Q=";
    npmDepsHash = "sha256-UFLLOCSuY/wVB+a0BDXmlJyj3oE6KOEZ36dq9TysNk0=";
    dontNpmBuild = true;
  };

  excalidraw = pkgs.buildNpmPackage {
    pname = "paseo-excalidraw";
    version = "0.1.0";
    src = github "lerenn" "paseo-excalidraw" "42e29c85f1e5ba7533473c2437e26265f48e73f6" "sha256-WfgaXxKAzlpvvrnd94Fw8G7oTxqAeZR5/2haCeOSmmI=";
    npmDepsHash = "sha256-K6H2IZNRPTIcnSi9vryyVHciMYSEejDtqQa5KppbZSw=";
    # The lockfile has unresolved peer conflicts; plain `npm ci` refetches.
    npmFlags = [ "--legacy-peer-deps" ];
  };

  # Plugin ID (from each paseo-plugin.json) -> directory the daemon loads.
  plugins = {
    progress = "${stevecastaneda}/progress";
    beautiful-chat = "${beautiful-chat}/lib/node_modules/beautiful-chat";
    paseo-cafe = "${cafe}/plugin";
    lobby = github "linhmh8" "agent-lobby" "3bb39e70134cc790de8a99fa4602473643912698" "sha256-U8t7QZoGq2JM0ytMQObDLS5E1QirjsmPGeuE2tORYlo=";
    annotations = github "neunzig-zehn" "paseo-annotations" "b921586b52cc2f937cf7814efc83d106310824fe" "sha256-AabTyHZ2FOUYfXMP0pQl7tfAmw9h5VRx8VNxTrdwRQ4=";
    excalidraw = "${excalidraw}/lib/node_modules/paseo-excalidraw";
    firstmate = "${github "gpambrozio" "paseo-plugins" "09509ce55ab06758623262e6aa71522ade6fda0c" "sha256-Ij84pzgakVx6mboHjfq41bu+AL+NljPxZnE7LUPYk98="}/firstmate";
    paseo-workboard = github "fxbing" "paseo-workboard" "596e4a246e50a963df618988835f9a1d83987f53" "sha256-Xv8CYXdWrDq6eiif8qPwh28a1De9TqSpzCtAf7fPy58=";
  };

  pluginSources = lib.mapAttrs (_: path: {
    source = "directory";
    path = "${path}";
  }) plugins;

  # claude-local (from ai-harnesses) as its own provider. Paseo would pass its
  # Anthropic model ids, which a local server does not serve; claude-local maps
  # the `opus` alias to the model it discovered.
  providers.claude-local = {
    extends = "claude";
    label = "Claude (local)";
    command = [ "claude-local" ];
    models = [
      {
        id = "opus";
        label = "Local model";
        isDefault = true;
      }
    ];
  };

  # Restart the daemon service from home/default.nix if it is running.
  restartDaemon =
    if pkgs.stdenv.hostPlatform.isDarwin then
      ''
        service="gui/$(id -u)/org.nix-community.home.paseo"
        if /bin/launchctl print "$service" >/dev/null 2>&1; then
          run /bin/launchctl kickstart -k "$service"
        fi
      ''
    else
      "run systemctl --user try-restart paseo.service";
in
{
  # The daemon owns config.json (app settings, Cafe installs), so merge our
  # plugins and providers into it instead of replacing the file.
  home.activation.paseoPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config="$HOME/.paseo/config.json"
    current='{"version":1}'
    [ -f "$config" ] && current="$(cat "$config")"
    run mkdir -p "$HOME/.paseo"
    printf '%s' "$current" \
      | ${pkgs.jq}/bin/jq --argjson plugins ${lib.escapeShellArg (builtins.toJSON pluginSources)} \
          --argjson providers ${lib.escapeShellArg (builtins.toJSON providers)} \
          '.pluginsEnabled = true | .plugins = (.plugins // {}) + $plugins
           | .agents.providers = (.agents.providers // {}) + $providers' \
      > "$config.tmp"
    # Plugin changes need a daemon restart (`paseo reload` skips them), so
    # restart only when the config changed to avoid killing agents every switch.
    if ! cmp -s "$config.tmp" "$config"; then
      run install -m 600 "$config.tmp" "$config"
      ${restartDaemon}
    fi
    rm "$config.tmp"
  '';
}
