# Atalhos rápidos

Plugin de barra `quickShortcuts` para DankMaterialShell 1.4.6, com suporte às
orientações horizontal e vertical. Licença MIT, autoria Matheuscara. Testado com Niri.

Os botões padrão abrem a pasta pessoal, notas e configurações nativas do DMS.
Terminal e editor aparecem somente quando você configura seus executáveis na
interface. Para substituir a lista inteira, configure `shortcutsJson` na interface
ou `shortcuts` como lista nas preferências declarativas:

```json
[{"name":"Meu editor","icon":"code","command":["meu-editor","/caminho/com espaço"]},{"name":"Site","icon":"language","url":"https://example.org"}]
```

`command` aceita uma lista de argumentos, sem shell intermediário; `url` aceita
`file:`, `http:` e `https:` e usa o aplicativo padrão. Os aplicativos indicados
precisam existir na máquina. Nenhum plugin adicional é exigido por padrão.
Uma lista vazia oculta os atalhos. JSON inválido mostra um botão de erro que abre
as configurações; nenhuma ação inválida é disparada.

[Configuração completa](https://github.com/Matheuscara/dayzWidgets/blob/main/docs/CONFIGURATION.md).
