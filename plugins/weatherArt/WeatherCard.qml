import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root
    minWidth: 280
    minHeight: 200

    readonly property var weather: WeatherService.weather
    readonly property bool available: weather.available

    Ref {
        service: WeatherService
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surface, 0.90)
        border.width: 1
        border.color: Theme.withAlpha(Theme.surfaceText, 0.09)
    }

    Text {
        x: 22
        y: 18
        width: parent.width - 76
        text: root.available ? root.weather.city : "Clima"
        font.family: SettingsData.fontFamily
        font.pixelSize: 14
        font.weight: Font.Medium
        color: Theme.surfaceText
        elide: Text.ElideRight
    }

    DankIcon {
        anchors.right: parent.right
        anchors.rightMargin: 22
        y: 20
        name: root.available ? WeatherService.getWeatherIcon(root.weather.wCode, root.weather.isDay) : "cloud_off"
        size: 22
        color: Theme.primary
    }

    Text {
        x: 22
        y: 46
        text: root.available ? WeatherService.formatTemp(root.weather.temp) : "—"
        font.family: SettingsData.fontFamily
        font.pixelSize: 44
        font.weight: Font.Light
        color: Theme.surfaceText
    }

    Text {
        x: 22
        y: 108
        width: parent.width - 44
        text: root.available ? WeatherService.getWeatherCondition(root.weather.wCode) : (root.weather.loading ? "Carregando previsão…" : "Clima indisponível")
        font.family: SettingsData.fontFamily
        font.pixelSize: 13
        color: Theme.surfaceVariantText
        elide: Text.ElideRight
    }

    Rectangle {
        x: 22
        y: 146
        width: parent.width - 44
        height: 1
        color: Theme.outlineVariant
    }

    Row {
        x: 22
        y: 163
        spacing: 22
        visible: root.available

        Row {
            spacing: 6
            DankIcon {
                name: "humidity_percentage"
                size: 16
                color: Theme.surfaceVariantText
            }
            Text {
                text: WeatherService.formatPercent(root.weather.humidity)
                font.family: SettingsData.fontFamily
                font.pixelSize: 12
                color: Theme.surfaceText
            }
        }

        Row {
            spacing: 6
            DankIcon {
                name: "air"
                size: 16
                color: Theme.surfaceVariantText
            }
            Text {
                text: root.available ? String(root.weather.wind) + " km/h" : "—"
                font.family: SettingsData.fontFamily
                font.pixelSize: 12
                color: Theme.surfaceText
            }
        }
    }
}
