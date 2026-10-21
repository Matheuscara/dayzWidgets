import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import "ShortcutConfig.js" as ShortcutConfig

PluginComponent {
    id: root

    readonly property var configuration: ShortcutConfig.read(pluginData, Quickshell.env("HOME"))
    readonly property var shortcuts: configuration.items

    function launch(shortcut) {
        if (shortcut.url)
            Qt.openUrlExternally(shortcut.url);
        else
            Quickshell.execDetached(shortcut.command);
    }

    onConfigurationChanged: {
        if (configuration.error)
            console.warn("QuickShortcuts:", configuration.error);
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS
            DankActionButton {
                visible: root.configuration.error !== ""
                buttonSize: 28
                iconSize: 18
                iconName: "error_outline"
                iconColor: Theme.warning
                tooltipText: root.configuration.error
                onClicked: PopoutService.openSettingsWithTab("plugins")
            }
            Repeater {
                model: root.shortcuts
                DankActionButton {
                    required property var modelData
                    required property int index
                    buttonSize: 28
                    iconSize: 17
                    iconName: modelData.icon
                    iconColor: Theme.widgetIconColor
                    tooltipText: modelData.name
                    tooltipSide: "bottom"
                    onClicked: root.launch(modelData)
                }
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS
            DankActionButton {
                visible: root.configuration.error !== ""
                buttonSize: 28
                iconSize: 18
                iconName: "error_outline"
                iconColor: Theme.warning
                tooltipText: root.configuration.error
                onClicked: PopoutService.openSettingsWithTab("plugins")
            }
            Repeater {
                model: root.shortcuts
                DankActionButton {
                    required property var modelData
                    buttonSize: 28
                    iconSize: 18
                    iconName: modelData.icon
                    iconColor: Theme.widgetIconColor
                    tooltipText: modelData.name
                    onClicked: root.launch(modelData)
                }
            }
        }
    }
}
