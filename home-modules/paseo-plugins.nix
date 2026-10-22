{ config, pkgs, lib, ... }:

let
  github =
    owner: repo: rev: hash:
    pkgs.fetchFromGitHub { inherit owner repo rev hash; };

  stevecastaneda = github "stevecastaneda" "paseo-plugins" "bea6aeabfdccc736c592104868d3789158a6263b" "sha256-8Z+exBYwY0R6InbAlPLuuCeSb+Dh+fIk0rpaVb7WPZQ=";
  cafe = github "paseo-cafe" "paseo-cafe" "6ad8ac037921e32dd2b72b127d9d9b4733a9fecf" "sha256-dH3IDCfcjMuBRsKyag7DypuwRWUPfeXOycZzKocBHAw=";

  # Plugins with npm dependencies. Paseo runs their manifest `build` steps only
  # for Git/npm installs, so Nix does that work here.
  excalidraw = pkgs.buildNpmPackage {
    pname = "paseo-excalidraw";
    version = "0.1.0";
    src = github "lerenn" "paseo-excalidraw" "42e29c85f1e5ba7533473c2437e26265f48e73f6" "sha256-WfgaXxKAzlpvvrnd94Fw8G7oTxqAeZR5/2haCeOSmmI=";
    npmDepsHash = "sha256-K6H2IZNRPTIcnSi9vryyVHciMYSEejDtqQa5KppbZSw=";
    # The lockfile has unresolved peer conflicts; plain `npm ci` refetches.
    npmFlags = [ "--legacy-peer-deps" ];
  };

  # build:cli bundles the paseo-progress command into dist/; without it the
  # command can't find zod.
  progress = pkgs.buildNpmPackage {
    pname = "paseo-progress";
    version = "1.3.1";
    src = "${stevecastaneda}/progress";
    npmDepsHash = "sha256-3DuELcaYH+7J/et/fxmAWaE6CASWPtryH3Zaz6HbjJQ=";
    npmBuildScript = "build:cli";
    # npm's install step runs the package's postpack, which deletes dist/.
    installPhase = "cp -r . $out";
  };

  # Plugin ID (from each paseo-plugin.json) -> directory the daemon loads.
  plugins = {
    progress = "${progress}";
    paseo-cafe = "${cafe}/plugin";
    lobby = github "linhmh8" "agent-lobby" "3bb39e70134cc790de8a99fa4602473643912698" "sha256-U8t7QZoGq2JM0ytMQObDLS5E1QirjsmPGeuE2tORYlo=";
    annotations = github "neunzig-zehn" "paseo-annotations" "b921586b52cc2f937cf7814efc83d106310824fe" "sha256-AabTyHZ2FOUYfXMP0pQl7tfAmw9h5VRx8VNxTrdwRQ4=";
    excalidraw = "${excalidraw}/lib/node_modules/paseo-excalidraw";
    firstmate = "${github "gpambrozio" "paseo-plugins" "09509ce55ab06758623262e6aa71522ade6fda0c" "sha256-Ij84pzgakVx6mboHjfq41bu+AL+NljPxZnE7LUPYk98="}/firstmate";
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
      "run ${config.systemd.user.systemctlPath} --user try-restart paseo.service";
in
{
  # The daemon owns config.json (app settings, Cafe installs), so merge our
  # plugins and providers into it instead of replacing the file. Store-path
  # plugins are ours, so drop any no longer listed.
  home.activation.paseoPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config="$HOME/.paseo/config.json"
    current='{"version":1}'
    [ -f "$config" ] && current="$(cat "$config")"
    run mkdir -p "$HOME/.paseo"
    printf '%s' "$current" \
      | ${pkgs.jq}/bin/jq --argjson plugins ${lib.escapeShellArg (builtins.toJSON pluginSources)} \
          --argjson providers ${lib.escapeShellArg (builtins.toJSON providers)} \
          '.pluginsEnabled = true
           | .plugins = ((.plugins // {})
               | with_entries(select(.value.path // "" | startswith("/nix/store/") | not)))
               + $plugins
           | .agents.providers = (.agents.providers // {}) + $providers' \
      > "$config.tmp"
    # Plugin changes need a daemon restart (`paseo reload` skips them), so
    # restart only when the config changed to avoid killing agents every switch.
    if ! cmp -s "$config.tmp" "$config"; then
      run install -m 600 "$config.tmp" "$config"
      ${restartDaemon}
    fi
    rm "$config.tmp"

    # Link the paseo-progress skill where the plugin's Install skill button
    # would, to the exact path it checks, so each switch keeps the link current
    # and the panel sees it as installed. Leaves real folders alone.
    for skills in "$HOME/.agents/skills" "$HOME/.claude/skills" "$HOME/.codex/skills"; do
      link="$skills/paseo-progress"
      if [ -L "$link" ] || [ ! -e "$link" ]; then
        run mkdir -p "$skills"
        run ln -sfn "${progress}/skills/paseo-progress" "$link"
      fi
    done
  '';
}
