final: prev: {
  nix-index-database = final.runCommandLocal "nix-index-database" {} ''
    mkdir -p $out
    ln -s ${
      inputs.nix-index-database.legacyPackages.${prev.system}.database
    } $out/files
  '';
};
