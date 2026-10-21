# Bitwarden · Acesso na barra

Plugin `bitwardenBar` · DMS 1.4.6 · MIT · autoria Matheuscara.

Integração específica com o [fork compatível](https://github.com/Matheuscara/dms-bitwarden-cli)
do plugin Bitwarden. Ele precisa estar instalado, habilitado e publicar
`PluginService.getGlobalVar("bitwarden", "vault")` com o método `toggleFromBar()`.
Sem essa integração, o botão fica desativado. Não é um cofre independente e não
cria sessão de login. A dependência não é instalada pelo instalador da coleção.

Este acesso foi retirado do pedido ao catálogo: depende de um fork não listado e
a integração deve ser tratada com o projeto Bitwarden de origem antes de cadastrar
uma variante. O código continua disponível para quem utiliza essa integração.

[Configuração](https://github.com/Matheuscara/dayzWidgets/blob/main/docs/CONFIGURATION.md).
