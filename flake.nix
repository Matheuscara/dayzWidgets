{
  description = "dayzWidgets — original and customized DankMaterialShell widgets";
  outputs = { self }: {
    nixosModules.default = import ./nix/module.nix;
  };
}
