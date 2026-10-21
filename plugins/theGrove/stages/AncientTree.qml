import QtQuick
import qs.Common

Item {
    id: root
    anchors.fill: parent
    property bool wilted: false

    readonly property color leafColor: wilted ? Qt.darker(Theme.primary, 1.3) : Theme.primary
    readonly property color trunkColor: "#5c4230"

    Rectangle {
        id: trunk
        width: parent.width * 0.16
        height: parent.height * 0.4
        radius: width * 0.15
        color: root.trunkColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.06
    }

    Repeater {
        model: 2
        Rectangle {
            required property int index
            property real side: index === 0 ? -1 : 1
            width: parent.width * 0.09
            height: parent.height * 0.09
            radius: height / 2
            color: root.trunkColor
            x: trunk.x + trunk.width / 2 + side * (trunk.width * 0.55 + width * 0.4) - width / 2
            y: trunk.y + trunk.height - height * 0.6
            transform: Rotation { angle: side * 30; origin.x: width / 2; origin.y: height / 2 }
        }
    }

    Repeater {
        model: [-40, 40, -65, 65, 0]
        Rectangle {
            required property var modelData
            property real angle: modelData
            width: parent.width * 0.07
            height: parent.height * 0.26
            radius: width / 2
            color: root.trunkColor
            transformOrigin: Item.Bottom
            x: trunk.x + trunk.width / 2 - width / 2
            y: trunk.y - height + trunk.height * 0.15
            rotation: angle
        }
    }

    Item {
        id: canopy
        width: parent.width
        height: parent.height * 0.62
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: trunk.top
        anchors.bottomMargin: parent.height * 0.1
        opacity: root.wilted ? 0.7 : 1

        Repeater {
            model: 16
            Rectangle {
                required property int index
                property real angle: index * 22.5
                property real radiusFrac: 0.24 + (index % 4) * 0.07
                width: canopy.width * 0.2
                height: canopy.height * 0.24
                radius: height / 2
                color: root.leafColor
                antialiasing: true
                x: canopy.width / 2 + canopy.width * radiusFrac * Math.sin(angle * Math.PI / 180) - width / 2
                y: canopy.height * 0.68 - canopy.height * radiusFrac * Math.cos(angle * Math.PI / 180) - height / 2
                rotation: root.wilted ? 12 : 0
            }
        }
    }
}
