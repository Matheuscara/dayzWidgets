# Changelog

## Dayz Wallpapers — 20-10-2026

- Oitavo plugin autoral: carrossel com categorias por pasta, navegação e aplicação nativa do wallpaper.
- Agendamento persistente por categoria, modo aleatório/sequencial, intervalo de 1–1440 minutos e pausa.
- Índice limitado, validação antes da aplicação, deduplicação de links e cache de miniaturas do DMS.
- Sete testes Python do índice/seletor; teste nativo isolado do timer de 60 segundos com o seletor fechado.
- Prévia ilustrativa sem fotos pessoais na grade do README.

## Envio pronto para revisão humana — 20-10-2026

- Revisão automática passou a `ready`, sem bloqueios; decisão de inclusão continua com os mantenedores.
- Hub substitui o atalho de keybinds dependente de provider pelo gerenciamento de plugins nativo.
- Ícones dos atalhos seguem escala e espessura da barra; galeria renomeada para Galeria de imagens.
- Diferencial em relação ao Media Frame documentado; compositor Niri mantido por ser o ambiente efetivamente testado.

## Segunda revisão do catálogo — 20-10-2026

- Hub independente dos módulos privados DankDash/DDash: cartões locais, calendário mensal e clima atual via WeatherService.
- Relógio respeita idioma e formato 12/24 h; retirado do cadastro por sobreposição, disponível no repositório.
- Categoria Sistema e status genérico no CommandShelf; controles seguem os tokens do tema.
- Primeiro lote reduzido a quatro plugins após retorno automático; texto do autor preservado.

## Portabilidade — 20-10-2026

- Hub com ferramentas configuráveis, funções nativas por padrão e sem injetar fundos na barra.
- Galeria com descoberta de imagens na pasta e abertura pelo aplicativo padrão, sem Wallpaper Carousel.
- CommandShelf lê atalhos opcionais do usuário; nenhuma combinação do compositor é presumida.
- QuickShortcuts configurável nas duas orientações e sem plugins extras por padrão; permissões de gravação corrigidas.
- Player com tokens nativos do tema; documentação de diferenças e dependência específica do Bitwarden.
- Testes Qt para JSON inválido, argumentos, IDs de instância e caminhos de imagem; CI Python e Qt aprovados.
- PR #1063 atualizado com cinco entradas e descrição fornecida pelo autor; nova revisão solicitada.
- Player separado em branch própria do fork do registro; BitwardenBar fora do cadastro.

## Envio ao catálogo — 20-10-2026

- Sete plugins autorais enviados ao registro oficial em [PR #1063](https://github.com/duxlabs-dev/dux-plugin-registry/pull/1063), aguardando avaliação.
- Validação de schema, URLs, caminhos e correspondência dos manifests; dez testes locais aprovados.
- Uso de IA e natureza ilustrativa das prévias declarados no pedido; adaptações excluídas para preservar os IDs upstream.

## README visual — 20-10-2026

- Prévias das cinco adaptações, incluindo árvore e contagem regressiva, com créditos e dados fictícios.
- Grade de duas colunas com oito prévias ilustrativas da coleção autoral e tema.
- Dados fictícios e render reproduzível com Chromium + ImageMagick, sem usar a sessão pessoal.

## 0.1.0 — 20-10-2026

- Publicação inicial: sete plugins autorais, cinco adaptações creditadas e tema Graphite.
- Instalador por links com prévia, proteção de instalações existentes e backups.
- Exemplos genéricos, documentação de configuração e módulo NixOS.
- Testes isolados do instalador e do catálogo de comandos; checks em CI.

## 2026-10-21 — distribuição Nix independente

- Dayz Wallpapers publicado também em `Matheuscara/dayzWallpapers`, com instalação
  por `nix run`, Python empacotado, backup e raiz de garbage collection.
- Documentadas as alternativas NixOS/Home Manager e a prevenção de instalações duplicadas.

- Interface do seletor e lista de plugins passam a exibir apenas **Wallpapers**; ID e atalhos preservados.
