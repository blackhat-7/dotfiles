{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "0.7.0";
  assets = {
    x86_64-linux = {
      name = "genmedia-linux-x64";
      hash = "sha256-cqOb0+sjcGr5ErYDUKnnKkum7EwOoTP1EdBY59dg/TQ=";
    };
    aarch64-linux = {
      name = "genmedia-linux-arm64";
      hash = "sha256-Cc/Z1FCeIIVpV8qDzxp2ZvCpcHNUY6d90OqbDpDjjhE=";
    };
    aarch64-darwin = {
      name = "genmedia-darwin-arm64";
      hash = "sha256-78BF8bUnwQIpCa4DJ7zOpmhFs0mW+IKZYwyePZ4r18Q=";
    };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system} or (throw "genmedia ${version} is not packaged for ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "genmedia";
  inherit version;

  src = fetchurl {
    url = "https://github.com/fal-ai-community/genmedia-cli/releases/download/v${version}/${asset.name}";
    hash = asset.hash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/genmedia"
    runHook postInstall
  '';

  meta = {
    description = "Agent-first CLI for fal generative media workflows";
    homepage = "https://github.com/fal-ai-community/genmedia-cli";
    license = lib.licenses.mit;
    mainProgram = "genmedia";
    platforms = builtins.attrNames assets;
  };
}
