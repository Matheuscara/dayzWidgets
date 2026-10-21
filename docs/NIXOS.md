# NixOS

O módulo fornecido pressupõe que você **já importou o módulo NixOS do DMS**, que
define `programs.dms-shell.plugins`. Ele só instala as fontes dos plugins; não mexe
em settings/session, cidade, wallpaper, instâncias ou credenciais.

Com flakes, adicione o input:

```nix
inputs.dayzWidgets.url = "github:Matheuscara/dayzWidgets";
```

E inclua em `modules` da sua configuração:

```nix
inputs.dayzWidgets.nixosModules.default
```

Ou importe `./nix/module.nix` a partir de um checkout local. Para escolher só alguns:

```nix
programs.dms-shell.plugins = {
  QuietClock.src = "${inputs.dayzWidgets}/plugins/QuietClock";
  NordMediaCard.src = "${inputs.dayzWidgets}/plugins/NordMediaCard";
};
```

Depois do rebuild, habilite e adicione as instâncias pela interface do DMS. Não
mantenha outra cópia de um mesmo ID no diretório do usuário; a precedência entre
origens pode variar por versão. O módulo contém plugins MIT e GPL-3.0, preservando
suas licenças. Dependências opcionais continuam sob controle da sua configuração.

O módulo é um ponto de integração com o módulo do DMS, não uma instalação completa
de Niri/Quickshell. Parse Nix e estrutura são verificados localmente; este repositório
não testa um nixos-rebuild completo para todas as versões de Nixpkgs/DMS.
