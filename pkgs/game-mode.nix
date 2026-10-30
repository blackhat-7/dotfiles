{
  writeShellApplication,
  scx,
  gawk,
  findutils,
}:

writeShellApplication {
  name = "game-mode";
  runtimeInputs = [
    gawk
    findutils
  ];
  # sudo resets PATH, so the scheduler is called by its store path.
  text = ''
    SCX_LAVD=${scx.full}/bin/scx_lavd
  ''
  + builtins.readFile ./game-mode.sh;
}
