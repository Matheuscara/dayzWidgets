# Galeria de imagens

Widget `animeGallery` para DankMaterialShell 1.4.6. Licença MIT, autoria Matheuscara.
Testado com Niri. Imagens são fornecidas pelo usuário; não há download ou coleção inclusa.

Adicione uma instância no desktop. Por padrão, procura JPG, PNG, WebP, AVIF e BMP
em `~/Pictures/Wallpapers`, sem subpastas. Clique para avançar; o botão de pasta
abre o diretório no aplicativo padrão do sistema. Não depende do Wallpaper Carousel.

Configure `directory` com uma pasta absoluta. Para usar subpastas, metadados ou
ordem manual, configure `manifestPath` com o caminho absoluto de um JSON:

```json
{"images":[{"file":"paisagens/exemplo.jpg","collection":"Paisagens","width":3840,"height":2160}]}
```

Arquivos são relativos à pasta escolhida. Caminhos absolutos e segmentos `..` são
rejeitados; metadados de coleção/dimensões são opcionais. O manifesto é observado
para atualizações. Se `manifestPath` estiver vazio, a descoberta da pasta é automática.
Configuração global fica no painel do plugin; instâncias podem usar `config.directory`
e `config.manifestPath` nas preferências do desktop.

[Configuração completa](https://github.com/Matheuscara/dayzWidgets/blob/main/docs/CONFIGURATION.md).

O catálogo também oferece [Media Frame](https://codeberg.org/claymorwan/dms-plugins/src/branch/master/mediaFrame),
voltado à exibição de uma imagem. Esta variante tem como foco navegar por uma
coleção local com descoberta da pasta, avanço por clique e ordem/metadados por
manifesto opcional. Mantém o ID `animeGallery` por compatibilidade, mas aceita
qualquer tema de imagens e não fornece conteúdo de anime.
