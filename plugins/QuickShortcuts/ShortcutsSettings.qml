import QtQuick
import qs.Modules.Plugins

PluginSettings {
    pluginId: "quickShortcuts"
    StringSetting {
        settingKey: "fileManager"
        label: "Gerenciador de arquivos"
        description: "Executável, sem argumentos de shell"
        defaultValue: "xdg-open"
    }
    StringSetting {
        settingKey: "terminal"
        label: "Terminal"
        defaultValue: "alacritty"
    }
    StringSetting {
        settingKey: "editor"
        label: "Editor"
        defaultValue: "zeditor"
    }
}
