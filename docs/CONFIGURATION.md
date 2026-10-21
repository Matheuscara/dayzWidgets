# Configuração

Os exemplos são referências para as estruturas do DMS; **não substitua seu
settings.json completo**. Prefira criar instâncias pela interface, que fornece
IDs e posições adequados ao monitor. O instalador só instala código.

## Relógio, mídia e clima

- QuietClock: adicione ao desktop e redimensione. O mostrador analógico aparece
  a partir de 360 px de largura. Recomendações: 336×128 ou 400×144.
- NordMediaCard: 336×132 ou 400×160; usa o player MPRIS ativo do DMS. O campo
  `transparency` no config da instância controla o fundo (padrão 0,90).
- weatherArt: configure cidade e coordenadas no **clima do DMS**, não no código.
  Recomendações: 336×212 ou 360×224.
- theGrove: configure nome e intervalo de rega; clique para regar. Não altere
  `firstLaunchDate`/`lastWatered` ao mudar aparência. Sem notificações por padrão
  no exemplo, mas a opção original continua disponível.

## Countdown com foto

Adicione uma ou mais instâncias de **DMS Desktop Countdown**. Campos:

| Campo | Exemplo | Efeito |
|---|---|---|
| `label` | Próximo evento | Título |
| `subtitle` | Preparar documentos | Descrição |
| `endDate` | 2027-01-01 | Data local, no formato YYYY-MM-DD |
| `backgroundImage` | file:///caminho/absoluto/foto.png | Fundo local |
| `imageDimAmount` | 0.62 | Escurecimento entre 0 e 1 |
| `eventIcon` | description | Material Symbol |
| `deadline` | true | Legenda Prazo |
| `dateCaption` | Até | Substitui a legenda da data |

[Config genérica](../examples/countdown.json). A imagem opcional
[travel-documents.png](../assets/travel-documents.png) foi gerada para a coleção;
usá-la requer apontar `backgroundImage` para o caminho absoluto do seu clone.
O texto/data são renderizados pelo QML. “Hoje” permanece durante o dia inteiro;
“Encerrado” aparece nos dias posteriores. Usa o fuso local do sistema.

## Galeria

AnimeGallery descobre imagens diretamente na pasta configurada (`directory`),
sem subpastas; o padrão é `~/Pictures/Wallpapers`. O botão abre essa pasta no
aplicativo padrão. Não exige Wallpaper Carousel.

Para escolher a ordem, incluir subpastas e informar metadados, configure um caminho
absoluto em `manifestPath`:

```json
{"images": [{"file": "paisagens/exemplo.jpg", "collection": "Paisagens", "width": 3840, "height": 2160}]}
```

O manifesto não baixa imagens. Caminhos são relativos à pasta; segmentos `..` e
caminhos absolutos são rejeitados. Coleção e dimensões são opcionais. Um manifesto
inválido mostra erro e não exibe os dados da configuração anterior.

## Atalhos

QuickShortcuts mostra por padrão arquivos, notas e configurações nativas.
Terminal e editor são opcionais. A lista completa pode ser definida em `shortcutsJson`
(texto JSON na interface) ou `shortcuts` (lista nas preferências declarativas):

```json
{"shortcuts": [{"name": "Editor", "icon": "code", "command": ["meu-editor", "/pasta/com espaço"]}]}
```

Também aceita `url` com esquema `file:`, `https:` ou `http:`. Comandos são listas de
argumentos sem shell intermediário. A mesma lista funciona nas duas orientações
da barra. Erros mostram um botão para abrir as configurações.

## Hub e IDs

NordHub usa apenas ferramentas nativas por padrão. Configure `toolsJson` no painel
do plugin ou `tools` nas preferências declarativas. Cada integração com outro plugin
é opcional e usa o ID informado por você. Nenhum ID pessoal é presumido e nenhum
fundo é injetado na barra. [Tipos e exemplo](../plugins/NordHub/README.md).

O terminal do painel é opcional; arquivos abrem com o aplicativo padrão do sistema.
As métricas de desempenho precisam de `dgop`; ausente, a página mostra um aviso.

```bash
dms ipc widget toggle nordHub
dms ipc widget toggleWith nordHub tools
```

## CommandShelf e Bitwarden

CommandShelf requer Python 3 e dms no PATH. Lê aliases/funções de topo do bash,
scripts locais e hosts concretos de SSH. Os atalhos são opcionais, definidos pelo
usuário em `~/.config/dayzWidgets/shortcuts.json`, como uma lista de objetos
`{"keys":"Super + X","description":"Minha ação"}`. Não executa
os itens. Nenhum catálogo é incluído no Git; a coleta ocorre localmente.

BitwardenBar usa o daemon compatível indicado no README. Não é um cofre independente,
não incorpora helpers/binários e não troca a configuração de autenticação.

## Temas e versão

`themes/graphite.json` é opcional e deve ser selecionado como tema customizado na
interface do DMS; o instalador não troca seu tema. A referência visual é o modo
escuro. Os plugins usam APIs internas de DMS 1.4.6 e preservam seus IDs, inclusive
nas adaptações: remova ou substitua instalações duplicadas antes de habilitar.
