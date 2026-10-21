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
        description: "Opcional: caminho absoluto. Vazio descobre automaticamente imagens na pasta, sem subpastas."
        defaultValue: ""
    }
}
