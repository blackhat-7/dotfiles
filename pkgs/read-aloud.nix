{
  stdenv,
  writeShellApplication,
  fetchzip,
  sherpa-onnx,
  perl,
  pipewire,
}:

let
  # The Kokoro voice Paseo uses.
  kokoro = fetchzip {
    url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/kokoro-en-v0_19.tar.bz2";
    hash = "sha256-Kjq29Rtn34qzkR06zG0JHR3P/eQdDUC6NPKn/WKqJs4=";
  };
in
writeShellApplication {
  name = "read-aloud";
  runtimeInputs = [
    sherpa-onnx
    perl
  ];
  runtimeEnv = {
    KOKORO = kokoro;
    PRONUNCIATIONS = ../nix/vocab/pronunciations.txt;
    PLAYER = if stdenv.hostPlatform.isDarwin then "/usr/bin/afplay" else "${pipewire}/bin/pw-play";
  };
  text = builtins.readFile ./read-aloud.sh;
}
