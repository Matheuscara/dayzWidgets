import QtQuick
import qs.Common

Item {
    id: root
    anchors.fill: parent
    property bool wilted: false

    readonly property color leafColor: wilted ? Qt.darker(Theme.primary, 1.3) : Theme.primary
    readonly property color trunkColor: "#6b4e34"

    Rectangle {
        id: trunk
        width: parent.width * 0.1
        height: parent.height * 0.4
        radius: width / 2
        color: root.trunkColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.05
    }

    Repeater {
        model: [-30, 30, -55, 55]
        Rectangle {
            required property var modelData
            property real angle: modelData
            width: parent.width * 0.06
            height: parent.height * (0.2 + Math.abs(angle) * 0.001)
            radius: width / 2
            color: root.trunkColor
            transformOrigin: Item.Bottom
            x: trunk.x + trunk.width / 2 - width / 2
            y: trunk.y - height + trunk.height * 0.2
            rotation: angle
        }
    }

    Item {
        id: canopy
        width: parent.width * 0.9
        height: parent.height * 0.55
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: trunk.top
        anchors.bottomMargin: parent.height * 0.08
        opacity: root.wilted ? 0.7 : 1

        Repeater {
            model: 12
            Rectangle {
                required property int index
                property real angle: index * 30
                property real radiusFrac: 0.28 + (index % 3) * 0.08
                width: canopy.width * 0.22
                height: canopy.height * 0.28
                radius: height / 2
                color: root.leafColor
                antialiasing: true
                x: canopy.width / 2 + canopy.width * radiusFrac * Math.sin(angle * Math.PI / 180) - width / 2
                y: canopy.height * 0.7 - canopy.height * radiusFrac * Math.cos(angle * Math.PI / 180) - height / 2
                rotation: root.wilted ? 10 : 0
            }
        }
    }
}
