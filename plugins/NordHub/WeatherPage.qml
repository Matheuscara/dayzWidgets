import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: page
    readonly property var weather: WeatherService.weather
    readonly property bool available: SettingsData.weatherEnabled && weather.available
    Component.onCompleted: WeatherService.addRef()
    Component.onDestruction: WeatherService.removeRef()

    HubCard {
        anchors.centerIn: parent
        width: Math.min(parent.width, 480)
        height: parent.height - Theme.spacingL
        Column {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacingM
            DankIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                name: page.available ? WeatherService.getWeatherIcon(page.weather.wCode, page.weather.isDay) : "cloud_off"
                size: Theme.iconSizeLarge * 2
                color: Theme.primary
            }
            StyledText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: page.available ? page.weather.city : (SettingsData.weatherEnabled ? (page.weather.loading ? "Carregando clima…" : "Clima indisponível") : "Clima desativado no DMS")
                font.pixelSize: Theme.fontSizeLarge
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
            }
            StyledText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                visible: page.available
                text: page.available ? WeatherService.formatTemp(page.weather.temp) : ""
                font.pixelSize: Theme.fontSizeXLarge * 2
            }
            StyledText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                visible: page.available
                text: page.available ? WeatherService.getWeatherCondition(page.weather.wCode) : ""
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.WordWrap
            }
            StyledText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                visible: page.available
                text: "Umidade " + (page.weather.humidity ?? "—") + "% · Vento " + (page.weather.wind || "—")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }
            DankActionButton {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: SettingsData.weatherEnabled && !page.weather.loading
                iconName: "refresh"
                tooltipText: "Atualizar clima"
                buttonSize: Theme.iconSizeSmall + Theme.spacingL
                iconSize: Theme.iconSizeSmall
                onClicked: WeatherService.forceRefresh()
            }
        }
    }
}
