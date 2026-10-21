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

Em AnimeGallery, configure a pasta absoluta das imagens e, opcionalmente, o
manifesto. O padrão é `~/Pictures/Wallpapers/manifest.json`. Cada item descreve um
arquivo relativo à pasta, coleção e dimensões reais:

```json
{"images": [{"file": "paisagens/exemplo.jpg", "collection": "Paisagens", "width": 3840, "height": 2160}]}
```

O manifesto não baixa imagens. O clique avança; o botão de coleção chama o
Wallpaper Carousel, se instalado separadamente. Use imagens que você possa usar.

## Atalhos

QuickShortcuts permite configurar terminal, editor e gerenciador na interface.
Executáveis não devem conter shell nem argumentos concatenados. Para controle
completo, `shortcuts` no config do plugin aceita uma lista:

```json
{"shortcuts": [{"name": "Terminal", "icon": "terminal", "command": ["alacritty"]}]}
```

O navegador usa o handler do sistema via xdg-open. Atalhos de plugins opcionais
exigem que esses plugins estejam instalados e tenham host na barra quando necessário.

## Hub e IDs

NordHub é uma central opcional. Ferramentas ausentes aparecem indisponíveis. Para
seus botões de desktop controlarem as instâncias corretas, use os IDs indicados no
[exemplo](../examples/desktop-instances.json), ou ajuste os targets de ToolsPage.qml
aos IDs gerados pelo seu DMS. Nada é ativado automaticamente.

```bash
dms ipc widget toggle nordHub
dms ipc widget toggleWith nordHub tools
```

## CommandShelf e Bitwarden

CommandShelf requer Python 3 e dms no PATH. Lê aliases/funções de topo do bash,
scripts locais, hosts concretos de SSH e atalhos declarados no helper. Não executa
os itens. Nenhum catálogo é incluído no Git; a coleta ocorre localmente.

BitwardenBar usa o daemon compatível indicado no README. Não é um cofre independente,
não incorpora helpers/binários e não troca a configuração de autenticação.

## Temas e versão

`themes/graphite.json` é opcional e deve ser selecionado como tema customizado na
interface do DMS; o instalador não troca seu tema. A referência visual é o modo
escuro. Os plugins usam APIs internas de DMS 1.4.6 e preservam seus IDs, inclusive
nas adaptações: remova ou substitua instalações duplicadas antes de habilitar.
