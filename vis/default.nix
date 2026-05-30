{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  plugins = {
    inherit (inputs) vis-tmux-repl vis-lspc;
  };
in
{
  home.packages = [
    (pkgs.vis.override {
      lua =
        with pkgs;
        lua
        // {
          withPackages = f: lua.withPackages (ps: f ps ++ (with ps; [ cjson ]));
        };
    })
  ];
  home.sessionVariables.EDITOR = "vis";
  home.file = {
    vis = {
      source = ./vis;
      target = ".config/vis";
      recursive = true;
    };
    visTheme = {
      source = inputs.base16-vis;
      target = ".config/vis/themes";
    };
  }
  // builtins.mapAttrs (name: plugin: {
    source = plugin;
    target = ".config/vis/plugins/${name}";
  }) plugins;
}
