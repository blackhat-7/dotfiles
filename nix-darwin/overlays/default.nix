# This file automatically finds and imports all other .nix files in this directory.

{ lib }:

let
  # The path to this current directory
  overlaysPath = ./.;

  # Read the contents of the directory, returning a set like:
  # { "default.nix" = "regular"; "karabiner-old.nix" = "regular"; }
  overlaysFiles = builtins.readDir overlaysPath;

  # Get a list of all file names that are NOT "default.nix" and end in ".nix"
  overlayFileNames =
    lib.attrNames (
      lib.filterAttrs (name: type:
        name != "default.nix" && lib.strings.hasSuffix ".nix" name && type == "regular"
      ) overlaysFiles
    );

  # Create a list of imported overlays by mapping over the list of file names
  importedOverlays =
    lib.map (fileName:
      # For each name, import its corresponding file
      import (overlaysPath + "/${fileName}")
    ) overlayFileNames;

in
# The final result of this file is the list of all imported overlays.
importedOverlays
