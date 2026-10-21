import QtQuick
import qs.Common

Item {
    id: root
    anchors.fill: parent
    property bool wilted: false

    readonly property color leafColor: wilted ? Qt.darker(Theme.primary, 1.3) : Theme.primary
    readonly property color trunkColor: "#7a5c3e"

    Rectangle {
        id: trunk
        width: parent.width * 0.06
        height: parent.height * 0.45
        radius: width / 2
        color: root.trunkColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.05
    }

    Repeater {
        model: 5
        Rectangle {
            required property int index
            property real angle: -60 + index * 30
            width: parent.width * 0.15
            height: width * 0.65
            radius: height / 2
            color: root.leafColor
            opacity: root.wilted ? 0.6 : 1
            antialiasing: true
            x: trunk.x + trunk.width / 2 + (parent.width * 0.28) * Math.sin(angle * Math.PI / 180) - width / 2
            y: trunk.y - (parent.height * 0.02) - (parent.width * 0.22) * Math.cos(angle * Math.PI / 180) - height / 2
            rotation: root.wilted ? angle * 0.3 + 15 : angle
        }
    }
}
