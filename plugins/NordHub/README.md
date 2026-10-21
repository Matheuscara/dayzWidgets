# Nord Hub

Central de barra para DankMaterialShell 1.4.6, com painel, desempenho, clima e
ferramentas pesquisáveis. Testado com Niri. Licença MIT, autoria Matheuscara.

Habilite `nordHub` e adicione-o à barra. O painel abre no centro do monitor.
`dgop` fornece as métricas; quando ausente, a página informa a indisponibilidade.
O Hub não altera o fundo nem a composição da barra.

Em **Configurações → Plugins → Nord Hub**, configure o executável do terminal
(opcional), a exibição do clima e `toolsJson`. Vazio usa apenas notas, atalhos e
configurações nativas. `[]` remove todas as ferramentas. JSON inválido apresenta
um erro e não dispara ações. Também é possível fornecer a lista `tools` diretamente
nas configurações declarativas do plugin.

Exemplo de `toolsJson`:

```json
[{"name":"Meu relógio","desc":"Mostrar ou ocultar","icon":"schedule","category":"desktop","kind":"desktop","target":"ID_DA_SUA_INSTANCIA","ipc":["desktopWidget","toggleEnabled","ID_DA_SUA_INSTANCIA"]}]
```

Tipos: `native` (IPC nativo), `app` (`command` como lista de argumentos),
`plugin` (plugin carregado), `widget` (host na barra) e `desktop` (instância existente).
Os três últimos exigem `target`; todos, exceto `app`, exigem `ipc` como lista.
Categorias: `util`, `media`, `wellbeing`, `system` e `desktop`.
A lista de comandos é fornecida por você: cadastre somente ações que deseja executar.
Plugins opcionais e IDs são definidos por quem instala, sem editar QML.

[Configuração completa](https://github.com/Matheuscara/dayzWidgets/blob/main/docs/CONFIGURATION.md).
