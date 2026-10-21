import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    readonly property var vault: PluginService.getGlobalVar("bitwarden", "vault", null)
    readonly property bool unlocked: vault?.status === "unlocked"
    enabled: vault !== null

    pillClickAction: function(x, y, width, section, screen) {
        if (!vault)
            return;
        vault.toggleFromBar({
            x: x, y: y, width: width, section: section, screen: screen,
            position: root.barConfig?.position ?? SettingsData.Position.Top,
            thickness: root.barThickness, spacing: root.barSpacing, config: root.barConfig
        });
    }

    horizontalBarPill: shieldPill
    verticalBarPill: shieldPill

    Component {
        id: shieldPill
        Item {
            implicitWidth: root.iconSize
            implicitHeight: root.iconSize
            opacity: root.enabled ? 1 : 0.45
            Accessible.name: "Bitwarden"

            DankIcon {
                anchors.centerIn: parent
                name: root.unlocked ? "verified_user" : "shield_lock"
                size: root.iconSize
                color: root.unlocked ? Theme.primary : Theme.widgetIconColor
            }

            HoverHandler { id: hover }
            ToolTip.visible: hover.hovered
            ToolTip.delay: 500
            ToolTip.text: root.vault ? "Bitwarden" : "Bitwarden indisponível"
        }
    }
}
