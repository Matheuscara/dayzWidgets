# Meus Comandos

Widget `commandShelf` para DankMaterialShell 1.4.6. Requer Python 3 e `dms` no PATH.
Licença MIT, autoria Matheuscara. Testado com Niri.

Adicione uma instância no desktop para pesquisar e copiar comandos locais.
O helper lê declarações de topo de `~/.bashrc`, scripts em `~/.local/bin`, aliases
em `/etc/bashrc` e hosts concretos em `~/.ssh/config`. Não interpreta o shell,
não segue includes de SSH e não executa os comandos encontrados.

Nenhum atalho de teclado é presumido. Para exibir seus atalhos, crie opcionalmente
`~/.config/dayzWidgets/shortcuts.json`:

```json
[{"keys":"Super + X","description":"Minha ação configurada no compositor"}]
```

O helper também aceita `--shortcuts-file /caminho/atalhos.json` ao ser usado pela CLI.
Arquivos ausentes são ignorados; atalhos malformados produzem aviso sem esconder
o restante do catálogo. Evite mostrar esse widget em gravações se seu catálogo
contiver nomes de hosts ou outros dados privados. Nenhum catálogo sai da máquina.

[Configuração completa](https://github.com/Matheuscara/dayzWidgets/blob/main/docs/CONFIGURATION.md).
