import QtQuick
import qs.Common

Item {
    id: root
    anchors.fill: parent
    property bool wilted: false

    readonly property color leafColor: wilted ? Qt.darker(Theme.primary, 1.3) : Theme.primary
    readonly property color stemColor: "#6b8f5a"

    Rectangle {
        id: stem
        width: 4
        height: parent.height * 0.35
        radius: 2
        color: root.stemColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.05
    }

    Rectangle {
        width: parent.width * 0.16
        height: width * 0.6
        radius: height / 2
        color: root.leafColor
        opacity: root.wilted ? 0.65 : 1
        anchors.bottom: stem.top
        anchors.bottomMargin: parent.height * 0.08
        anchors.horizontalCenter: stem.horizontalCenter
        anchors.horizontalCenterOffset: -width * 0.9
        rotation: root.wilted ? 20 : -25
    }

    Rectangle {
        width: parent.width * 0.16
        height: width * 0.6
        radius: height / 2
        color: root.leafColor
        opacity: root.wilted ? 0.65 : 1
        anchors.bottom: stem.top
        anchors.bottomMargin: parent.height * 0.02
        anchors.horizontalCenter: stem.horizontalCenter
        anchors.horizontalCenterOffset: width * 0.9
        rotation: root.wilted ? -20 : 25
    }
}
