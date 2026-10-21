import QtQuick
import qs.Modules.Plugins

PluginSettings {
    pluginId: "nordHub"
    StringSetting {
        settingKey: "toolsJson"
        label: "Ferramentas (JSON)"
        description: "Lista de ferramentas; vazio usa apenas funções nativas do DMS. Exemplos no README."
        defaultValue: ""
    }
    StringSetting {
        settingKey: "terminal"
        label: "Terminal"
        description: "Executável opcional, sem argumentos de shell; vazio oculta o botão."
        defaultValue: ""
    }
    ToggleSetting {
        settingKey: "showWeatherInBar"
        label: "Mostrar clima na barra"
        defaultValue: false
    }
}
