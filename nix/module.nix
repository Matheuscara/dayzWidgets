{ ... }:
let
  root = ../plugins;
  entries = builtins.readDir root;
  names = builtins.filter (
    name: entries.${name} == "directory" && builtins.pathExists (root + "/${name}/plugin.json")
  ) (builtins.attrNames entries);
in
{
  programs.dms-shell.plugins = builtins.listToAttrs (
    map (name: {
      inherit name;
      value.src = root + "/${name}";
    }) names
  );
}
