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
        width: parent.width * 0.08
        height: parent.height * 0.42
        radius: width / 2
        color: root.trunkColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.05
    }

    Rectangle {
        id: forkLeft
        width: parent.width * 0.05
        height: parent.height * 0.22
        radius: width / 2
        color: root.trunkColor
        transformOrigin: Item.Bottom
        x: trunk.x + trunk.width * 0.15
        y: trunk.y - height + trunk.height * 0.1
        rotation: -28
    }

    Rectangle {
        id: forkRight
        width: parent.width * 0.05
        height: parent.height * 0.22
        radius: width / 2
        color: root.trunkColor
        transformOrigin: Item.Bottom
        x: trunk.x + trunk.width * 0.55
        y: trunk.y - height + trunk.height * 0.1
        rotation: 28
    }

    Repeater {
        model: 7
        Rectangle {
            required property int index
            property real angle: -75 + index * 25
            width: parent.width * 0.17
            height: width * 0.68
            radius: height / 2
            color: root.leafColor
            opacity: root.wilted ? 0.6 : 1
            antialiasing: true
            x: trunk.x + trunk.width / 2 + (parent.width * 0.32) * Math.sin(angle * Math.PI / 180) - width / 2
            y: trunk.y - trunk.height * 0.75 - (parent.width * 0.3) * Math.cos(angle * Math.PI / 180) - height / 2
            rotation: root.wilted ? angle * 0.3 + 15 : angle
        }
    }
}
