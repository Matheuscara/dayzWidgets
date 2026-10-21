import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import "CalendarData.js" as CalendarData

HubCard {
    id: root
    property date month: new Date(clock.date.getFullYear(), clock.date.getMonth(), 1)
    readonly property var dates: CalendarData.cells(month.getFullYear(), month.getMonth(), Qt.locale().firstDayOfWeek)
    SystemClock { id: clock; precision: SystemClock.Minutes }

    Row {
        id: header
        width: parent.width
        spacing: Theme.spacingXS
        DankActionButton {
            iconName: "chevron_left"
            buttonSize: Theme.iconSizeSmall + Theme.spacingS
            iconSize: Theme.iconSizeSmall
            tooltipText: "Mês anterior"
            onClicked: root.month = new Date(root.month.getFullYear(), root.month.getMonth() - 1, 1)
        }
        StyledText {
            width: header.width - (Theme.iconSizeSmall + Theme.spacingS) * 2 - header.spacing * 2
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            text: root.month.toLocaleDateString(Qt.locale(), "MMMM yyyy")
            font.pixelSize: Theme.fontSizeMedium
            elide: Text.ElideRight
        }
        DankActionButton {
            iconName: "chevron_right"
            buttonSize: Theme.iconSizeSmall + Theme.spacingS
            iconSize: Theme.iconSizeSmall
            tooltipText: "Próximo mês"
            onClicked: root.month = new Date(root.month.getFullYear(), root.month.getMonth() + 1, 1)
        }
    }
    Grid {
        anchors.top: header.bottom
        anchors.topMargin: Theme.spacingS
        anchors.bottom: parent.bottom
        width: parent.width
        columns: 7
        Repeater {
            model: 49
            Rectangle {
                required property int index
                readonly property date day: root.dates[index < 7 ? index : index - 7]
                readonly property bool today: index >= 7 && day.toDateString() === clock.date.toDateString()
                width: parent.width / 7
                height: parent.height / 7
                radius: Theme.cornerRadius / 2
                color: today ? Theme.primary : "transparent"
                StyledText {
                    anchors.centerIn: parent
                    text: parent.index < 7 ? parent.day.toLocaleDateString(Qt.locale(), "ddd") : parent.day.getDate()
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: parent.today ? Font.Medium : Font.Normal
                    color: parent.today ? Theme.primaryText : (parent.index < 7 || parent.day.getMonth() !== root.month.getMonth() ? Theme.surfaceVariantText : Theme.surfaceText)
                }
            }
        }
    }
}
