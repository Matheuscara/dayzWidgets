import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    readonly property int visibleCount: (parentScreen?.width ?? 1920) < 1600 ? 5 : 9
    readonly property var shortcuts: Array.isArray(pluginData.shortcuts) ? pluginData.shortcuts : [
        { name: "Arquivos", icon: "folder_open", command: [pluginData.fileManager || "xdg-open", Quickshell.env("HOME")] },
        { name: "Terminal", icon: "terminal", command: [pluginData.terminal || "alacritty"] },
        { name: "Navegador", icon: "language", command: ["xdg-open", "https://github.com"] },
        { name: "Editor", icon: "code", command: [pluginData.editor || "zeditor"] },
        { name: "Notas rápidas", icon: "edit_note", command: ["dms", "ipc", "notepad", "toggle"] },
        { name: "Clipboard+", icon: "content_paste", command: ["dms", "ipc", "widget", "toggle", "clipboardPlus"] },
        { name: "OCR", icon: "document_scanner", command: ["dms", "ipc", "widget", "toggle", "ocrScanner"] },
        { name: "Docker", icon: "deployed_code", command: ["dms", "ipc", "widget", "toggle", "dockerManager"] },
        { name: "Wallpapers", icon: "wallpaper", command: ["dms", "ipc", "wallpaperCarousel", "toggle"] }
    ]

    horizontalBarPill: Component {
        Row {
            spacing: 3
            Repeater {
                model: root.shortcuts
                DankActionButton {
                    required property var modelData
                    required property int index
                    visible: index < root.visibleCount
                    buttonSize: 28
                    iconSize: 17
                    iconName: modelData.icon
                    iconColor: Theme.widgetIconColor
                    tooltipText: modelData.name
                    tooltipSide: "bottom"
                    onClicked: Quickshell.execDetached(modelData.command)
                }
            }
        }
    }

    verticalBarPill: Component {
        DankActionButton {
            buttonSize: 28
            iconSize: 18
            iconName: "bolt"
            tooltipText: "Central de ferramentas"
            onClicked: Quickshell.execDetached(["dms", "ipc", "widget", "toggleWith", "nordHub", "tools"])
        }
    }
}
