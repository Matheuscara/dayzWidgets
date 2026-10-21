import QtQuick
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property var pluginService: null
    property string pluginId: ""
    property string instanceId: ""
    property var instanceData: null
    property real widgetWidth: 440
    property real widgetHeight: 150
    property real defaultWidth: 440
    property real defaultHeight: 150
    property real minWidth: 320
    property real minHeight: 132

    readonly property real backgroundOpacity: instanceData?.config?.transparency ?? 0.90
    property MprisPlayer player: MprisController.activePlayer
    readonly property bool hasPlayer: !!player
    readonly property bool playing: player?.playbackState === MprisPlaybackState.Playing
    readonly property real length: player?.length ?? 0
    readonly property real position: player?.position ?? 0
    readonly property real progress: length > 0 ? Math.max(0, Math.min(1, position / length)) : 0
    readonly property int feedbackDuration: Math.min(160, Theme.shortDuration)

    function formatTime(seconds) {
        if (!seconds || seconds < 0)
            return "0:00";
        const s = Math.floor(seconds);
        const h = Math.floor(s / 3600);
        const m = Math.floor((s % 3600) / 60);
        return (h > 0 ? h + ":" : "") + (h > 0 && m < 10 ? "0" : "") + m + ":" + (s % 60 < 10 ? "0" : "") + s % 60;
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.visible && root.playing && (root.player?.positionSupported ?? false)
        onTriggered: root.player.positionChanged()
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surface, root.backgroundOpacity)
        border.width: 1
        border.color: Theme.withAlpha(Theme.surfaceText, 0.09)
    }

    ClippingRectangle {
        id: artwork
        x: 18
        y: 18
        width: Math.max(64, Math.min(88, root.height - 72))
        height: width
        radius: 12
        color: Theme.withAlpha(Theme.surfaceContainerHighest, 0.7)

        DankIcon {
            anchors.centerIn: parent
            name: root.hasPlayer ? "album" : "music_note"
            size: 30
            color: Theme.surfaceVariantText
            visible: cover.status !== Image.Ready
        }

        Image {
            id: cover
            anchors.fill: parent
            source: root.player?.trackArtUrl ?? ""
            sourceSize.width: 256
            sourceSize.height: 256
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: status === Image.Ready ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: root.feedbackDuration }
            }
        }
    }

    Column {
        id: trackInfo
        anchors.left: artwork.right
        anchors.leftMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 18
        y: 20
        spacing: 4

        StyledText {
            width: parent.width
            text: root.hasPlayer ? (root.player.trackTitle || "Sem título") : "Nada tocando"
            textFormat: Text.PlainText
            font.pixelSize: 15
            font.weight: Font.Medium
            color: Theme.surfaceText
            elide: Text.ElideRight
        }

        StyledText {
            width: parent.width
            text: root.hasPlayer ? (root.player.trackArtist || root.player.identity || "") : "Sua música aparece aqui"
            textFormat: Text.PlainText
            font.pixelSize: 12
            color: Theme.surfaceVariantText
            elide: Text.ElideRight
        }
    }

    Row {
        anchors.left: trackInfo.left
        anchors.top: trackInfo.bottom
        anchors.topMargin: 8
        spacing: 8
        visible: root.hasPlayer

        DankActionButton {
            anchors.verticalCenter: parent.verticalCenter
            iconName: "skip_previous"
            buttonSize: 28
            iconSize: 18
            tooltipText: "Faixa anterior"
            enabled: root.player?.canGoPrevious ?? false
            opacity: enabled ? 1 : 0.35
            onClicked: root.player.previous()
        }

        Rectangle {
            width: 34
            height: 34
            radius: 12
            color: Theme.primary
            scale: playArea.pressed && Theme.shortDuration > 0 ? 0.94 : 1
            Behavior on scale {
                NumberAnimation {
                    duration: root.feedbackDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.23, 1, 0.32, 1, 1, 1]
                }
            }
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Theme.primaryText
                opacity: playArea.containsMouse ? 0.10 : 0
                Behavior on opacity { NumberAnimation { duration: root.feedbackDuration } }
            }
            DankIcon {
                anchors.centerIn: parent
                name: root.playing ? "pause" : "play_arrow"
                size: 20
                filled: true
                color: Theme.primaryText
            }
            MouseArea {
                id: playArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: root.player?.canTogglePlaying ?? false
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.player.togglePlaying()
            }
        }

        DankActionButton {
            anchors.verticalCenter: parent.verticalCenter
            iconName: "skip_next"
            buttonSize: 28
            iconSize: 18
            tooltipText: "Próxima faixa"
            enabled: root.player?.canGoNext ?? false
            opacity: enabled ? 1 : 0.35
            onClicked: root.player.next()
        }
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        height: 20
        visible: root.hasPlayer && root.length > 0

        StyledText {
            id: elapsed
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: root.formatTime(root.position)
            font.pixelSize: 11
            color: Theme.surfaceVariantText
        }

        StyledText {
            id: duration
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.formatTime(root.length)
            font.pixelSize: 11
            color: Theme.surfaceVariantText
        }

        Item {
            id: seek
            anchors.left: elapsed.right
            anchors.right: duration.left
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            height: parent.height

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 3
                radius: 1.5
                color: Theme.surfaceContainerHighest
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 3
                radius: 1.5
                color: Theme.primary
                transformOrigin: Item.Left
                scale: 1
                transform: Scale { xScale: root.progress }
            }
            Rectangle {
                x: Math.max(0, Math.min(parent.width - width, parent.width * root.progress - width / 2))
                anchors.verticalCenter: parent.verticalCenter
                width: 8
                height: 8
                radius: 4
                color: Theme.primary
                opacity: seekArea.containsMouse ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: root.feedbackDuration } }
            }
            MouseArea {
                id: seekArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: (root.player?.canSeek ?? false) && root.length > 0
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: mouse => root.player.position = Math.min(Math.max(0, mouse.x / width) * root.length, root.length * 0.99)
            }
        }
    }
}
