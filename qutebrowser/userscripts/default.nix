{
  lib,
  callPackage,
  bsm,
  prefix ? "",
}:
let
  scripts = [
    "bsmadd"
    "open-dictionary"
    "open-in-brave"
    "rbw"
    "update-filter-list"
    "webarchive"
  ];
in
lib.genAttrs scripts (name: callPackage (./. + "/${name}.nix") { inherit bsm prefix; })
