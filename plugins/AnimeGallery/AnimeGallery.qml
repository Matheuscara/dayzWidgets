import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root
    minWidth: 260
    minHeight: 170

    readonly property string directory: pluginData.directory || (Quickshell.env("HOME") + "/Pictures/Wallpapers")
    property var pictures: []
    property int currentIndex: 0
    readonly property var current: pictures.length ? pictures[currentIndex % pictures.length] : null

    FileView {
        path: root.pluginData.manifestPath || (root.directory + "/manifest.json")
        watchChanges: true
        onLoaded: {
            try {
                root.pictures = JSON.parse(text()).images.filter(p => typeof p.file === "string" && !p.file.includes("..") && !p.file.startsWith("/"));
            } catch (_) {
                root.pictures = [];
            }
        }
    }

    HoverHandler { id: galleryHover }

    ClippingRectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.surface

        Image {
            anchors.fill: parent
            source: root.current ? "file://" + root.directory + "/" + root.current.file : ""
            sourceSize.width: 800
            sourceSize.height: 450
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            scale: galleryHover.hovered && Theme.shortDuration > 0 ? 1.025 : 1
            Behavior on scale {
                NumberAnimation {
                    duration: Math.min(200, Theme.shortDuration)
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.23, 1, 0.32, 1, 1, 1]
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: root.currentIndex = (root.currentIndex + 1) % Math.max(1, root.pictures.length)
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 42
            color: Theme.withAlpha(Theme.surface, 0.94)

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                StyledText {
                    text: root.current ? root.current.collection.replace("Anime-", "") : "Galeria vazia"
                    textFormat: Text.PlainText
                    font.pixelSize: 12
                    color: Theme.surfaceText
                }
                StyledText {
                    text: root.current ? root.current.width + "×" + root.current.height + " · clique para avançar" : "Adicione wallpapers à coleção"
                    font.pixelSize: 10
                    color: Theme.surfaceVariantText
                }
            }

            DankActionButton {
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                buttonSize: 30
                iconSize: 18
                iconName: "collections"
                iconColor: Theme.primary
                tooltipText: "Escolher wallpaper"
                onClicked: Quickshell.execDetached(["dms", "ipc", "wallpaperCarousel", "open"])
            }
        }
    }
}
