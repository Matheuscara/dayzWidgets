import QtQuick
import qs.Modules.Plugins

PluginSettings {
    pluginId: "quickShortcuts"
    StringSetting {
        settingKey: "shortcutsJson"
        label: "Atalhos (JSON)"
        description: "Lista opcional: name, icon e command (lista de argumentos) ou url. Vazio usa funções nativas."
        defaultValue: ""
    }
    StringSetting {
        settingKey: "terminal"
        label: "Terminal"
        description: "Executável opcional; vazio oculta o botão."
        defaultValue: ""
    }
    StringSetting {
        settingKey: "editor"
        label: "Editor"
        description: "Executável opcional; vazio oculta o botão."
        defaultValue: ""
    }
}
