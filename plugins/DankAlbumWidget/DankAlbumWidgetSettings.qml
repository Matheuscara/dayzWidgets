import QtQuick
import qs.Common
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "dankAlbumWidget"

    ToggleSetting {
        settingKey: "hideWhenIdle"
        label: I18n.tr("Hide When Idle")
        description: I18n.tr("Fade the widget out when no MPRIS player is active")
        defaultValue: false
    }
}
