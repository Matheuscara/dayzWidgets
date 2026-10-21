import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: page

    signal requestClose

    readonly property string dmsBin: "dms"
    readonly property real gap: Theme.spacingS
    readonly property int columns: 4
    readonly property real cardHeight: 74

    // Bumped by registry/plugin signals so availability bindings re-evaluate.
    property int revision: 0
    property string category: "all"
    readonly property string query: searchField.text.trim().toLowerCase()

    readonly property var categories: [
        {
            "id": "all",
            "text": "Tudo"
        },
        {
            "id": "util",
            "text": "Utilitários"
        },
        {
            "id": "media",
            "text": "Mídia"
        },
        {
            "id": "wellbeing",
            "text": "Bem-estar"
        },
        {
            "id": "system",
            "text": "Sistema"
        },
        {
            "id": "desktop",
            "text": "Desktop"
        }
    ]

    // kind: "plugin" (IPC owned by a loaded plugin), "widget" (collapsed bar host),
    // "desktop" (desktop widget instance), "native" (always present in DMS).
    readonly property var tools: [
        {"name": "Galeria Anime", "desc": "Quadro interativo dos seus wallpapers", "icon": "photo_library", "category": "desktop", "kind": "desktop", "target": "dayz_gallery", "hideOnEnable": ["dayz_album"], "ipc": ["desktopWidget", "toggleEnabled", "dayz_gallery"], "keywords": "wallpaper foto quadro galeria anime"},
        {"name": "Capa de álbum", "desc": "Capa quadrada e controles de música", "icon": "album", "category": "desktop", "kind": "desktop", "target": "dayz_album", "hideOnEnable": ["dayz_gallery"], "ipc": ["desktopWidget", "toggleEnabled", "dayz_album"], "keywords": "album capa musica mpris"},
        {"name": "Contagem regressiva", "desc": "Dias até uma data configurável", "icon": "event_upcoming", "category": "desktop", "kind": "desktop", "target": "dayz_countdown", "ipc": ["desktopWidget", "toggleEnabled", "dayz_countdown"], "keywords": "countdown dias prazo meta"},
        {"name": "Tarefas", "desc": "Lista local com subtarefas e filtros", "icon": "checklist", "category": "util", "kind": "widget", "target": "dankTodo", "ipc": ["widget", "toggle", "dankTodo"], "keywords": "todo tarefas lista checklist"},
        {
            "name": "Wallpapers",
            "desc": "Coleções de anime em 2K e 4K",
            "icon": "photo_library",
            "category": "media",
            "kind": "app",
            "target": "",
            "command": ["xdg-open", Quickshell.env("HOME") + "/Pictures/Wallpapers"],
            "keywords": "wallpapers anime pasta colecao 2k 4k imagens"
        },
        {
            "name": "Clima",
            "desc": "Temperatura, condição e umidade",
            "icon": "partly_cloudy_day",
            "category": "desktop",
            "kind": "desktop",
            "target": "dayz_weather",
            "hideOnEnable": ["dayz_system_monitor"],
            "ipc": ["desktopWidget", "toggleEnabled", "dayz_weather"],
            "keywords": "weather clima ascii tempo previsao"
        },
        {
            "name": "Minha árvore",
            "desc": "Clique para regar e acompanhar",
            "icon": "park",
            "category": "desktop",
            "kind": "desktop",
            "target": "dayz_grove",
            "hideOnEnable": ["dayz_calendar"],
            "ipc": ["desktopWidget", "toggleEnabled", "dayz_grove"],
            "keywords": "grove arvore planta regar jardim"
        },
        {
            "name": "Relógio Nothing",
            "desc": "Alternar com o relógio atual",
            "icon": "schedule",
            "category": "desktop",
            "kind": "desktop",
            "target": "dayz_nothing_clock",
            "replaces": "dayz_clock",
            "ipc": ["desktopWidget", "toggleEnabled", "dayz_nothing_clock"],
            "keywords": "nothing clock relogio analogico digital orbit"
        },
        {
            "name": "Busca web / GitHub",
            "desc": "!gh projeto · !yt vídeo · !g busca",
            "icon": "travel_explore",
            "category": "util",
            "kind": "plugin",
            "target": "dankQuickSearch",
            "ipc": ["launcher", "openQuery", "!"],
            "keywords": "web github google youtube quick search pesquisa"
        },
        {
            "name": "Conversor",
            "desc": "Unidades e temperatura: `32f-c",
            "icon": "compare_arrows",
            "category": "util",
            "kind": "plugin",
            "target": "converter",
            "ipc": ["launcher", "openQuery", "`"],
            "keywords": "converter unidades medidas temperatura peso"
        },
        {
            "name": "Notas rápidas",
            "desc": "Bloco de notas do desktop",
            "icon": "edit_note",
            "category": "util",
            "kind": "native",
            "target": "",
            "ipc": ["notepad", "toggle"],
            "keywords": "notas notepad texto rascunho"
        },
        {
            "name": "Atalhos",
            "desc": "Consultar atalhos de teclado",
            "icon": "keyboard",
            "category": "util",
            "kind": "native",
            "target": "",
            "ipc": ["keybinds", "toggle"],
            "keywords": "atalhos teclado shortcut keybind"
        },
        {
            "name": "Meus Comandos",
            "desc": "Mostrar/ocultar o catálogo",
            "icon": "terminal",
            "category": "desktop",
            "kind": "desktop",
            "target": "dayz_commands",
            "ipc": ["desktopWidget", "toggleEnabled", "dayz_commands"],
            "keywords": "comandos catalogo shell nix ssh"
        },
        {
            "name": "Monitor do sistema",
            "desc": "Mostrar/ocultar CPU, RAM e rede",
            "icon": "monitoring",
            "category": "desktop",
            "kind": "desktop",
            "target": "dayz_system_monitor",
            "ipc": ["desktopWidget", "toggleEnabled", "dayz_system_monitor"],
            "keywords": "sistema cpu ram memoria metricas"
        },
        {
            "name": "Calculadora",
            "desc": "Abre o launcher em modo cálculo",
            "icon": "calculate",
            "category": "util",
            "kind": "plugin",
            "target": "calculator",
            "ipc": ["launcher", "openQuery", "= "],
            "keywords": "calculator conta matematica ="
        },
        {
            "name": "Emoji",
            "desc": "Seletor de emojis",
            "icon": "mood",
            "category": "util",
            "kind": "plugin",
            "target": "emojiPicker",
            "ipc": ["emojiPicker", "toggle"],
            "keywords": "emoji picker"
        },
        {
            "name": "Kaomoji",
            "desc": "Busca kaomoji no launcher",
            "icon": "sentiment_very_satisfied",
            "category": "util",
            "kind": "plugin",
            "target": "kaomojiPicker",
            "ipc": ["launcher", "openQuery", "kj "],
            "keywords": "kaomoji kj"
        },
        {
            "name": "Clipboard+",
            "desc": "Histórico, notas e tarefas",
            "icon": "content_paste",
            "category": "util",
            "kind": "widget",
            "target": "clipboardPlus",
            "ipc": ["widget", "toggle", "clipboardPlus"],
            "keywords": "clipboard area de transferencia notas todo"
        },
        {
            "name": "OCR",
            "desc": "Texto de imagens copiadas",
            "icon": "document_scanner",
            "category": "util",
            "kind": "widget",
            "target": "ocrScanner",
            "ipc": ["widget", "toggle", "ocrScanner"],
            "keywords": "ocr scanner tesseract texto"
        },
        {
            "name": "Downloader",
            "desc": "Baixar mídia com yt-dlp",
            "icon": "download",
            "category": "util",
            "kind": "widget",
            "target": "mediaDownloader",
            "ipc": ["widget", "toggle", "mediaDownloader"],
            "keywords": "media downloader youtube yt-dlp video audio"
        },
        {
            "name": "Bitwarden",
            "desc": "Cofre; login e desbloqueio manuais",
            "icon": "key",
            "category": "util",
            "kind": "plugin",
            "target": "bitwarden",
            "ipc": ["bitwarden", "toggle"],
            "keywords": "bitwarden senha password cofre vault"
        },
        {
            "name": "Mídia+",
            "desc": "Player com capa e seekbar",
            "icon": "music_note",
            "category": "media",
            "kind": "widget",
            "target": "mediaControlPlus",
            "ipc": ["widget", "toggle", "mediaControlPlus"],
            "keywords": "media midia player musica mpris"
        },
        {
            "name": "Áudio",
            "desc": "Volume, microfone e dispositivos",
            "icon": "volume_up",
            "category": "media",
            "kind": "widget",
            "target": "simpleAudioControl",
            "ipc": ["widget", "toggle", "simpleAudioControl"],
            "keywords": "audio som volume saida microfone"
        },
        {
            "name": "Som ambiente",
            "desc": "Nada toca até você escolher",
            "icon": "forest",
            "category": "media",
            "kind": "widget",
            "target": "ambientSound",
            "ipc": ["widget", "toggle", "ambientSound"],
            "keywords": "ambient som ambiente chuva foco"
        },
        {
            "name": "Espelho",
            "desc": "Câmera só ativa ao abrir; nada automático",
            "icon": "photo_camera",
            "category": "media",
            "kind": "widget",
            "target": "handMirror",
            "ipc": ["widget", "toggle", "handMirror"],
            "keywords": "camera espelho mirror webcam"
        },
        {
            "name": "Respiração",
            "desc": "Exercícios guiados",
            "icon": "air",
            "category": "wellbeing",
            "kind": "widget",
            "target": "breathing",
            "ipc": ["widget", "toggle", "breathing"],
            "keywords": "breathing respiracao relaxar"
        },
        {
            "name": "Pausas",
            "desc": "Lembretes de descanso",
            "icon": "self_improvement",
            "category": "wellbeing",
            "kind": "widget",
            "target": "takeABreak",
            "ipc": ["widget", "toggle", "takeABreak"],
            "keywords": "take a break pausa descanso"
        },
        {
            "name": "Timer",
            "desc": "Contagem regressiva",
            "icon": "timer",
            "category": "wellbeing",
            "kind": "widget",
            "target": "timer",
            "ipc": ["widget", "toggle", "timer"],
            "keywords": "timer cronometro contagem"
        },
        {
            "name": "Docker",
            "desc": "Containers e compose",
            "icon": "deployed_code",
            "category": "system",
            "kind": "widget",
            "target": "dockerManager",
            "ipc": ["widget", "toggle", "dockerManager"],
            "keywords": "docker container compose"
        },
        {
            "name": "IP",
            "desc": "Consulta pública só manual",
            "icon": "public",
            "category": "system",
            "kind": "widget",
            "target": "ipIndicator",
            "ipc": ["widget", "toggle", "ipIndicator"],
            "keywords": "ip rede network endereco"
        },
        {
            "name": "NetBird",
            "desc": "Status e peers; sem conectar ao abrir",
            "icon": "vpn_lock",
            "category": "system",
            "kind": "widget",
            "target": "netbirdStatus",
            "ipc": ["widget", "toggle", "netbirdStatus"],
            "keywords": "netbird vpn peers rede status"
        },
        {
            "name": "Lutris",
            "desc": "Jogos instalados",
            "icon": "sports_esports",
            "category": "system",
            "kind": "widget",
            "target": "lutrisLauncher",
            "ipc": ["widget", "toggle", "lutrisLauncher"],
            "keywords": "lutris jogos games"
        },
        {
            "name": "Monitores",
            "desc": "Perfis de tela do Niri",
            "icon": "monitor",
            "category": "system",
            "kind": "plugin",
            "target": "niriDS",
            "ipc": ["niriDS", "toggle"],
            "keywords": "niri display monitor tela"
        },
        {
            "name": "Wallpapers",
            "desc": "Carrossel de papéis de parede",
            "icon": "wallpaper",
            "category": "system",
            "kind": "plugin",
            "target": "wallpaperCarousel",
            "ipc": ["wallpaperCarousel", "toggle"],
            "keywords": "wallpaper papel de parede carousel"
        },
        {
            "name": "Plugins",
            "desc": "Configurações dos plugins",
            "icon": "extension",
            "category": "system",
            "kind": "native",
            "target": "",
            "ipc": ["settings", "openWith", "plugins"],
            "keywords": "plugins configuracoes settings"
        },
        {
            "name": "Grupos desktop",
            "desc": "Alternar grupos de widgets",
            "icon": "widgets",
            "category": "desktop",
            "kind": "widget",
            "target": "desktopWidgetToggle",
            "ipc": ["widget", "toggle", "desktopWidgetToggle"],
            "keywords": "desktop widget grupos"
        },
        {
            "name": "Arquivos",
            "desc": "Mostrar/ocultar no desktop",
            "icon": "folder_open",
            "category": "desktop",
            "kind": "desktop",
            "target": "dms_file_manager",
            "ipc": ["desktopWidget", "toggleEnabled", "dms_file_manager"],
            "keywords": "arquivos files desktop"
        },
        {
            "name": "GitHub heatmap",
            "desc": "Mostrar/ocultar no desktop",
            "icon": "grid_view",
            "category": "desktop",
            "kind": "desktop",
            "target": "dayz_github",
            "ipc": ["desktopWidget", "toggleEnabled", "dayz_github"],
            "keywords": "github heatmap contribuicoes desktop"
        },
        {
            "name": "EnderPulse",
            "desc": "Mostrar/ocultar no desktop",
            "icon": "graphic_eq",
            "category": "desktop",
            "kind": "desktop",
            "target": "enderpulse_visualizer",
            "ipc": ["desktopWidget", "toggleEnabled", "enderpulse_visualizer"],
            "keywords": "enderpulse visualizer audio desktop"
        },
        {
            "name": "Calendário P5",
            "desc": "Mostrar/ocultar no desktop",
            "icon": "calendar_month",
            "category": "desktop",
            "kind": "desktop",
            "target": "dayz_calendar",
            "requiredWidget": "desktopWidgetToggle",
            "ipc": ["desktopWidgetToggle", "toggleGroup", "calendar"],
            "keywords": "persona calendario desktop"
        }
    ]

    readonly property var filteredTools: {
        const q = page.query;
        const cat = page.category;
        return page.tools.filter(t => {
            if (cat !== "all" && t.category !== cat)
                return false;
            if (!q)
                return true;
            return (t.name + " " + t.desc + " " + t.keywords).toLowerCase().indexOf(q) !== -1;
        });
    }

    // Empty string when the tool can be launched, otherwise the reason it cannot.
    function unavailableReason(tool) {
        page.revision;
        if (tool.requiredWidget && !BarWidgetService.hasWidget(tool.requiredWidget))
            return "Host da barra inativo";
        switch (tool.kind) {
        case "plugin":
            return PluginService.isPluginLoaded(tool.target) ? "" : "Plugin desativado";
        case "widget":
            return BarWidgetService.hasWidget(tool.target) ? "" : "Host da barra inativo";
        case "desktop":
            return SettingsData.getDesktopWidgetInstance(tool.target) ? "" : "Instância não configurada";
        default:
            return "";
        }
    }

    function desktopState(tool) {
        if (tool.kind !== "desktop")
            return "";
        const instance = SettingsData.getDesktopWidgetInstance(tool.target);
        if (!instance)
            return "";
        return (instance.enabled ?? true) ? "Visível" : "Oculto";
    }

    function categoryColor(cat) {
        switch (cat) {
        case "media":
            return Theme.secondary;
        case "wellbeing":
            return Theme.info;
        case "system":
            return Theme.warning;
        default:
            return Theme.primary;
        }
    }

    function launch(tool) {
        if (!tool || page.unavailableReason(tool) !== "")
            return;
        if (tool.kind === "app") {
            page.requestClose();
            Quickshell.execDetached(tool.command);
            return;
        }
        if (tool.kind === "desktop" && (tool.replaces || tool.hideOnEnable)) {
            const nextEnabled = !(SettingsData.getDesktopWidgetInstance(tool.target).enabled ?? true);
            if (tool.replaces)
                SettingsData.updateDesktopWidgetInstance(tool.replaces, { enabled: !nextEnabled });
            if (nextEnabled) {
                for (const id of tool.hideOnEnable || [])
                    SettingsData.updateDesktopWidgetInstance(id, { enabled: false });
            }
            SettingsData.updateDesktopWidgetInstance(tool.target, { enabled: nextEnabled });
            page.requestClose();
            return;
        }
        const argv = [page.dmsBin, "ipc", "call"].concat(tool.ipc);
        page.requestClose();
        Quickshell.execDetached(argv);
    }

    function launchFirst() {
        const first = page.filteredTools.find(t => page.unavailableReason(t) === "");
        if (first)
            page.launch(first);
    }

    implicitWidth: 744
    implicitHeight: 410

    Connections {
        target: BarWidgetService
        function onWidgetRegistered() {
            page.revision++;
        }
        function onWidgetUnregistered() {
            page.revision++;
        }
    }

    Connections {
        target: PluginService
        function onPluginLoaded() {
            page.revision++;
        }
        function onPluginUnloaded() {
            page.revision++;
        }
    }

    Item {
        id: toolbar

        width: parent.width
        height: 36

        DankTextField {
            id: searchField

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 240
            height: parent.height
            placeholderText: "Buscar ferramenta"
            leftIconName: "search"
            leftIconSize: Theme.iconSizeSmall
            showClearButton: true
            onAccepted: page.launchFirst()
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacingXS

            Repeater {
                model: page.categories

                Rectangle {
                    id: chip

                    required property var modelData
                    readonly property bool selected: page.category === modelData.id

                    width: chipLabel.implicitWidth + Theme.spacingM * 2
                    height: 28
                    radius: height / 2
                    color: selected ? Theme.withAlpha(Theme.primary, 0.18) : (chipArea.containsMouse ? Theme.surfaceTextHover : Theme.withAlpha(Theme.surfaceContainerHigh, 0.6))
                    border.width: 1
                    border.color: selected ? Theme.withAlpha(Theme.primary, 0.6) : Theme.outlineMedium

                    StyledText {
                        id: chipLabel

                        anchors.centerIn: parent
                        text: chip.modelData.text
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: chip.selected ? Font.Medium : Font.Normal
                        color: chip.selected ? Theme.primary : Theme.surfaceText
                    }

                    MouseArea {
                        id: chipArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: page.category = chip.modelData.id
                    }
                }
            }
        }
    }

    DankGridView {
        id: grid

        anchors.top: toolbar.bottom
        anchors.topMargin: Theme.spacingM
        anchors.bottom: footer.top
        anchors.bottomMargin: Theme.spacingS
        width: parent.width
        clip: true
        model: page.filteredTools
        cellWidth: width / page.columns
        cellHeight: page.cardHeight + page.gap

        delegate: Item {
            id: cell

            required property var modelData
            readonly property string reason: page.unavailableReason(modelData)
            readonly property bool available: reason === ""
            readonly property string stateText: page.desktopState(modelData)
            readonly property color accent: page.categoryColor(modelData.category)

            width: grid.cellWidth
            height: grid.cellHeight

            Rectangle {
                id: card

                x: 0
                y: 0
                width: parent.width - page.gap
                height: page.cardHeight
                radius: Theme.cornerRadius
                opacity: cell.available ? 1 : 0.5
                color: cell.available && cardArea.containsMouse ? Theme.withAlpha(cell.accent, 0.12) : Theme.withAlpha(Theme.surfaceContainerHigh, 0.6)
                border.width: 1
                border.color: cell.available && cardArea.containsMouse ? Theme.withAlpha(cell.accent, 0.6) : Theme.outlineMedium

                Rectangle {
                    id: iconBadge

                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingM
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    height: 36
                    radius: 18
                    color: Theme.withAlpha(cell.accent, 0.16)

                    DankIcon {
                        anchors.centerIn: parent
                        name: cell.modelData.icon
                        size: Theme.iconSizeSmall + 2
                        color: cell.available ? cell.accent : Theme.surfaceVariantText
                        filled: cell.available && cardArea.containsMouse
                    }
                }

                Column {
                    anchors.left: iconBadge.right
                    anchors.leftMargin: Theme.spacingS
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Row {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            id: titleLabel

                            width: Math.min(implicitWidth, parent.width - (stateBadge.visible ? stateBadge.width + parent.spacing : 0))
                            text: cell.modelData.name
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            font.pixelSize: Theme.fontSizeSmall + 1
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        Rectangle {
                            id: stateBadge

                            anchors.verticalCenter: titleLabel.verticalCenter
                            visible: cell.stateText !== ""
                            width: stateLabel.implicitWidth + Theme.spacingS
                            height: stateLabel.implicitHeight + 2
                            radius: height / 2
                            color: cell.stateText === "Visível" ? Theme.withAlpha(Theme.primary, 0.18) : Theme.withAlpha(Theme.surfaceVariantText, 0.14)

                            StyledText {
                                id: stateLabel

                                anchors.centerIn: parent
                                text: cell.stateText
                                font.pixelSize: Theme.fontSizeSmall - 2
                                color: cell.stateText === "Visível" ? Theme.primary : Theme.surfaceVariantText
                            }
                        }
                    }

                    StyledText {
                        width: parent.width
                        text: cell.available ? cell.modelData.desc : cell.reason
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        font.pixelSize: Theme.fontSizeSmall - 1
                        color: cell.available ? Theme.surfaceVariantText : Theme.warning
                    }
                }

                MouseArea {
                    id: cardArea

                    anchors.fill: parent
                    enabled: cell.available
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: page.launch(cell.modelData)
                }
            }
        }
    }

    Column {
        anchors.centerIn: grid
        spacing: Theme.spacingS
        visible: page.filteredTools.length === 0

        DankIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: "search_off"
            size: Theme.iconSizeLarge
            color: Theme.surfaceVariantText
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Nenhuma ferramenta encontrada"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
        }
    }

    StyledText {
        id: footer

        anchors.bottom: parent.bottom
        width: parent.width
        text: page.tools.length + " ferramentas · Enter abre o primeiro resultado · Super+Shift+G alterna o modo do desktop"
        elide: Text.ElideRight
        maximumLineCount: 1
        font.pixelSize: Theme.fontSizeSmall - 2
        color: Theme.surfaceVariantText
    }
}
