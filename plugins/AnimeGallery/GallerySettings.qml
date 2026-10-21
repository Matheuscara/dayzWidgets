import QtQuick
import qs.Modules.Plugins

PluginSettings {
    pluginId: "animeGallery"
    StringSetting {
        settingKey: "directory"
        label: "Pasta das imagens"
        description: "Caminho absoluto; padrão: ~/Pictures/Wallpapers"
        defaultValue: ""
    }
    StringSetting {
        settingKey: "manifestPath"
        label: "Manifesto JSON"
        description: "Opcional; padrão: manifest.json dentro da pasta das imagens"
        defaultValue: ""
    }
}
