import QtQuick
import Quickshell.Services.Mpris
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root

    width: widgetWidth
    height: widgetHeight
    implicitWidth: widgetWidth
    implicitHeight: widgetHeight

    minWidth: 140
    minHeight: 140
    readonly property int defaultWidth: 240
    readonly property int defaultHeight: 240
    readonly property bool forceSquare: true

    property bool hideWhenIdle: pluginData.hideWhenIdle ?? false

    property MprisPlayer activePlayer: MprisController.activePlayer
    property real scrollAccumulatorY: 0
    property real touchpadThreshold: 100
    property string lastArtUrl: ""

    readonly property bool hoverPreview: false
    readonly property bool hasPlayer: activePlayer !== null && !hoverPreview
    readonly property bool hideChrome: hideWhenIdle && !hasPlayer
    readonly property bool isPlaying: hasPlayer && activePlayer.playbackState === MprisPlaybackState.Playing

    readonly property color accent: Theme.primary
    readonly property color onAccent: Theme.primaryText

    readonly property string artUrl: {
        const p = activePlayer;
        if (!p)
            return "";
        if (p.trackArtUrl)
            return p.trackArtUrl;
        const m = p.metadata;
        return m && m["mpris:artUrl"] ? m["mpris:artUrl"].toString() : "";
    }
    readonly property string displayArt: artUrl || lastArtUrl
    readonly property bool hasArt: displayArt !== "" && hasPlayer

    onArtUrlChanged: {
        if (artUrl !== "")
            lastArtUrl = artUrl;
        if (!hasPlayer)
            lastArtUrl = "";
    }

    readonly property real side: Math.min(width, height)
    readonly property int playSize: Math.round(Math.max(44, Math.min(64, side * 0.22)))
    readonly property int skipSize: Math.round(Math.max(36, Math.min(52, playSize * 0.82)))
    readonly property int playIconSize: Math.round(playSize * 0.5)
    readonly property int skipIconSize: Math.round(skipSize * 0.5)
    readonly property int controlMargin: Math.round(Math.max(Theme.spacingS, side * 0.06))
    readonly property int controlSpacing: Math.round(Math.max(Theme.spacingS, side * 0.04))

    function handleVolumeWheel(wheelEvent) {
        if (root.hideChrome || !AudioService.sink?.audio)
            return;

        wheelEvent.accepted = true;
        const deltaY = wheelEvent.angleDelta.y;
        if (deltaY === 0)
            return;

        const step = AudioService.wheelVolumeStep || SettingsData.audioWheelScrollAmount || 5;
        const isMouseWheelY = Math.abs(deltaY) >= 120 && (Math.abs(deltaY) % 120) === 0;
        if (isMouseWheelY) {
            AudioService.adjustDefaultSinkVolume(String(step), deltaY > 0 ? 1 : -1);
            return;
        }

        root.scrollAccumulatorY += deltaY;
        if (Math.abs(root.scrollAccumulatorY) >= root.touchpadThreshold) {
            AudioService.adjustDefaultSinkVolume("1", root.scrollAccumulatorY > 0 ? 1 : -1);
            root.scrollAccumulatorY = 0;
        }
    }

    ClippingRectangle {
        id: sleeve
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.surface
        visible: !root.hideChrome

        Image {
            id: cover
            anchors.fill: parent
            source: root.displayArt
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            visible: root.hasArt && status === Image.Ready
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            z: 1
            onWheel: wheel => root.handleVolumeWheel(wheel)
        }

        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingS
            visible: !cover.visible
            width: parent.width - Theme.spacingL * 2

            DankIcon {
                name: "album"
                size: Math.round(Math.max(Theme.iconSizeLarge, root.side * 0.28))
                color: Theme.surfaceVariantText
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                visible: !root.hasPlayer
                text: "Toque uma música"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Math.round(root.playSize + root.controlMargin * 2.4)
            visible: root.hasPlayer

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Theme.withAlpha(Theme.surface, 0)
                }
                GradientStop {
                    position: 1.0
                    color: Theme.withAlpha(Theme.surface, 0.55)
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.controlMargin
            spacing: root.controlSpacing
            z: 2

            DankActionButton {
                buttonSize: root.skipSize
                radius: root.skipSize / 2
                iconName: "skip_previous"
                iconSize: root.skipIconSize
                iconColor: Theme.surfaceText
                backgroundColor: Theme.withAlpha(Theme.surfaceContainerHighest, 0.78)
                enabled: root.hasPlayer
                tooltipText: I18n.tr("Previous")
                onClicked: root.activePlayer?.previous()
            }

            StyledRect {
                width: root.playSize
                height: root.playSize
                radius: root.playSize / 2
                color: root.accent
                opacity: root.hasPlayer ? 1 : 0.45

                DankIcon {
                    anchors.centerIn: parent
                    name: root.isPlaying ? "pause" : "play_arrow"
                    size: root.playIconSize
                    color: root.onAccent
                }

                StateLayer {
                    disabled: !root.hasPlayer || !(root.activePlayer?.canTogglePlaying ?? false)
                    stateColor: root.onAccent
                    cornerRadius: parent.radius
                    tooltipText: root.isPlaying ? I18n.tr("Pause") : I18n.tr("Play")
                    onClicked: {
                        if (root.activePlayer?.canTogglePlaying)
                            root.activePlayer.togglePlaying();
                    }
                }
            }

            DankActionButton {
                buttonSize: root.skipSize
                radius: root.skipSize / 2
                iconName: "skip_next"
                iconSize: root.skipIconSize
                iconColor: Theme.surfaceText
                backgroundColor: Theme.withAlpha(Theme.surfaceContainerHighest, 0.78)
                enabled: root.hasPlayer
                tooltipText: I18n.tr("Next")
                onClicked: root.activePlayer?.next()
            }
        }
    }
}
