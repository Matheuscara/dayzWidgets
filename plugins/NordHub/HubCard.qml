import QtQuick
import qs.Common

Rectangle {
    id: root
    property real pad: Theme.spacingM
    default property alias contents: body.data
    color: Theme.surfaceContainer
    radius: Theme.cornerRadius
    border.width: 1
    border.color: Theme.outlineMedium

    Item {
        id: body
        anchors.fill: parent
        anchors.margins: root.pad
    }
}
