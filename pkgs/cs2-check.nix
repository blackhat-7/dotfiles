{
  writeShellApplication,
  procps,
  util-linux,
  gawk,
  jq,
  lm_sensors,
  iputils,
  iproute2,
}:

writeShellApplication {
  name = "cs2-check";
  # hyprctl and journalctl come from the host.
  runtimeInputs = [
    procps
    util-linux
    gawk
    jq
    lm_sensors
    iputils
    iproute2
  ];
  text = builtins.readFile ./cs2-check.sh;
}
