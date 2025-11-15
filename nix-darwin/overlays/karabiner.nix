final: prev: {
  # We are adding a new package to the set.
  karabiner-elements-old = prev.buildFromBrew {
    name = "karabiner-elements";
    
    # Data for the specific old version
    version = "14.13.0";
    sha256 = "0e1c09a25d2b7949dbef1c120894a460395780affc23f66c08535805553d1007";
    url = "https://github.com/pqrs-org/Karabiner-Elements/releases/download/v14.13.0/Karabiner-Elements-14.13.0.dmg";

    sourceRoot = "Karabiner-Elements.app";
    installPhase = ''
      mkdir -p $out/Applications
      cp -R . $out/Applications/
    '';
  };
}
