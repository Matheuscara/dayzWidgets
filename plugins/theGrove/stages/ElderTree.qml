import QtQuick
import qs.Common

Item {
    id: root
    anchors.fill: parent
    property bool wilted: false

    readonly property color leafColor: wilted ? Qt.darker(Theme.primary, 1.3) : Theme.primary
    readonly property color trunkColor: "#4d3826"

    Rectangle {
        id: trunk
        width: parent.width * 0.2
        height: parent.height * 0.38
        radius: width * 0.1
        color: root.trunkColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.06

        Rectangle {
            width: parent.width * 0.3
            height: parent.height * 0.5
            radius: 4
            color: root.trunkColor
            x: -width * 0.6
            y: parent.height * 0.3
            rotation: -15
        }

        Rectangle {
            width: parent.width * 0.3
            height: parent.height * 0.5
            radius: 4
            color: root.trunkColor
            x: parent.width - width * 0.4
            y: parent.height * 0.35
            rotation: 15
        }
    }

    Repeater {
        model: 2
        Rectangle {
            required property int index
            property real side: index === 0 ? -1 : 1
            width: parent.width * 0.11
            height: parent.height * 0.1
            radius: height / 2
            color: root.trunkColor
            x: trunk.x + trunk.width / 2 + side * (trunk.width * 0.6 + width * 0.4) - width / 2
            y: trunk.y + trunk.height - height * 0.55
            rotation: side * 35
        }
    }

    Repeater {
        model: [-45, 45, -70, 70, -20, 20]
        Rectangle {
            required property var modelData
            property real angle: modelData
            width: parent.width * 0.08
            height: parent.height * 0.3
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
        width: parent.width * 1.05
        height: parent.height * 0.68
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: trunk.top
        anchors.bottomMargin: parent.height * 0.12
        opacity: root.wilted ? 0.65 : 1

        Repeater {
            model: 20
            Rectangle {
                required property int index
                property real angle: index * 18
                property real radiusFrac: 0.22 + (index % 5) * 0.07
                width: canopy.width * 0.18
                height: canopy.height * 0.22
                radius: height / 2
                color: root.leafColor
                antialiasing: true
                x: canopy.width / 2 + canopy.width * radiusFrac * Math.sin(angle * Math.PI / 180) - width / 2
                y: canopy.height * 0.66 - canopy.height * radiusFrac * Math.cos(angle * Math.PI / 180) - height / 2
                rotation: root.wilted ? 14 : 0
            }
        }
    }
}
