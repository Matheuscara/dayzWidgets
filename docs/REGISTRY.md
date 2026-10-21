# Publicação no catálogo

O [PR #1063](https://github.com/duxlabs-dev/dux-plugin-registry/pull/1063) foi
corrigido e marcado como pronto para nova revisão em 20-10-2026.
O catálogo depende da decisão dos mantenedores; não confunda checks aprovados
com inclusão na lista pública.

O primeiro lote contém cinco entradas: QuietClock, QuickShortcuts, AnimeGallery,
CommandShelf e NordHub. IDs e nomes coincidem com os manifests; os caminhos
apontam para as respectivas pastas deste monorepo. O texto de apresentação foi
fornecido pelo autor e mantido sem reescrita, com identificação do auxílio de IA no código.

O player tem uma [branch separada de preparação](https://github.com/Matheuscara/dms-plugin-registry/tree/add-dayz-media-card)
para tratar o diferencial em relação aos players já existentes. Não há segundo PR
aberto. BitwardenBar continua disponível na coleção, mas foi removido do pedido
porque depende de um fork não listado. As cinco adaptações não são novas entradas
porque preservam seus IDs de origem.

Validação: schema do registro; links de imagens/repos; pastas de monorepo;
correspondência de IDs/nomes; 12 testes Python e sete casos Qt (mais setup/cleanup).
A sintaxe dos 15 arquivos QML das áreas modificadas também foi conferida.
O teste isolado da galeria carregou o componente com o host desktop do DMS 1.4.6
e componentes visuais substitutos para verificar descoberta, pasta vazia e manifesto
inválido. Isso não equivale a testar a sessão completa nem versões novas do shell.

Referência: [regras oficiais de contribuição](https://github.com/duxlabs-dev/dux-plugin-registry/blob/master/CONTRIBUTING.md).
