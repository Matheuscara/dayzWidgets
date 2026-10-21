# Publicação no catálogo

O [PR #1063](https://github.com/duxlabs-dev/dux-plugin-registry/pull/1063) foi
corrigido e marcado como pronto para nova revisão em 20-10-2026.
O catálogo depende da decisão dos mantenedores; não confunda checks aprovados
com inclusão na lista pública.

O primeiro lote contém quatro entradas: QuickShortcuts, AnimeGallery,
CommandShelf e NordHub. QuietClock foi retirado por sobreposição com outros relógios. IDs e nomes coincidem com os manifests; os caminhos
apontam para as respectivas pastas deste monorepo. O texto de apresentação foi
fornecido pelo autor e mantido sem reescrita, com identificação do auxílio de IA no código.

O player tem uma [branch separada de preparação](https://github.com/Matheuscara/dms-plugin-registry/tree/add-dayz-media-card)
para tratar o diferencial em relação aos players já existentes. Não há segundo PR
aberto. BitwardenBar continua disponível na coleção, mas foi removido do pedido
porque depende de um fork não listado. As cinco adaptações não são novas entradas
porque preservam seus IDs de origem.

Validação: schema do registro; links de imagens/repos; pastas de monorepo;
correspondência de IDs/nomes; 12 testes Python e oito casos Qt (mais setup/cleanup).
A sintaxe dos 19 arquivos QML das áreas modificadas também foi conferida.
O teste isolado da galeria carregou o componente com o host desktop do DMS 1.4.6
e componentes visuais substitutos para verificar descoberta, pasta vazia e manifesto
inválido. Isso não equivale a testar a sessão completa nem versões novas do shell.

Referência: [regras oficiais de contribuição](https://github.com/duxlabs-dev/dux-plugin-registry/blob/master/CONTRIBUTING.md).

A segunda revisão reconheceu as correções iniciais e apontou a mudança de nomes
DankDash/DDash. O Hub passou a usar cartões, calendário mensal e visão de clima
locais, mantendo WeatherService para os dados. QuietClock recebeu correções de
locale, 12/24 horas e tokens, mas foi removido do cadastro por sobreposição.
CommandShelf usa a categoria genérica Sistema e não se refere a comandos de ajuda
particulares. O texto do autor permanece no PR, sem reescrita.

A [terceira revisão automática](https://github.com/duxlabs-dev/dux-plugin-registry/pull/1063#issuecomment-6305964878)
marcou o pedido como **ready**, sem bloqueios. As observações menores resultaram
em um botão nativo de plugins no lugar de keybinds sem provider, ícones da barra
escaláveis e nome genérico da galeria. A comparação com Media Frame foi documentada.
A lista de compositores continua restrita a Niri porque esse foi o ambiente testado;
o código não é deliberadamente limitado a ele. Aprovação humana e inclusão no site
continuam pendentes.
