import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root
    minWidth: 280
    minHeight: 128

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
        onDateChanged: dial.requestPaint()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.withAlpha(Theme.surface, 0.90)
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Theme.withAlpha(Theme.surfaceText, 0.09)
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingXL
        anchors.verticalCenter: parent.verticalCenter
        width: root.width - Theme.spacingXL * 2 - (dial.visible ? dial.width + Theme.spacingM : 0)
        spacing: Theme.spacingXS

        StyledText {
            width: parent.width
            text: clock.date.toLocaleTimeString(Qt.locale(), SettingsData.use24HourClock ? "HH:mm" : "h:mm AP")
            font.pixelSize: Math.min(Theme.fontSizeXLarge * 2.7, width / Math.max(1, text.length) * 1.5)
            font.weight: Font.Light
            color: Theme.surfaceText
        }
        StyledText {
            width: parent.width
            text: clock.date.toLocaleDateString()
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            elide: Text.ElideRight
        }
    }

    Canvas {
        id: dial
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingXL
        anchors.verticalCenter: parent.verticalCenter
        width: 64
        height: 64
        visible: root.width >= 360
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.translate(32, 32);
            for (let i = 0; i < 12; i++) {
                const angle = i * Math.PI / 6;
                ctx.fillStyle = i % 3 === 0 ? Theme.primary.toString() : Theme.surfaceVariantText.toString();
                ctx.globalAlpha = i % 3 === 0 ? 0.9 : 0.35;
                ctx.beginPath();
                ctx.arc(Math.sin(angle) * 27, -Math.cos(angle) * 27, i % 3 === 0 ? 1.8 : 1, 0, Math.PI * 2);
                ctx.fill();
            }
            ctx.globalAlpha = 1;
            const minutes = clock.date.getMinutes();
            const hours = clock.date.getHours() % 12 + minutes / 60;
            function hand(angle, length, thickness, color) {
                ctx.strokeStyle = color;
                ctx.lineWidth = thickness;
                ctx.lineCap = "round";
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(Math.sin(angle) * length, -Math.cos(angle) * length);
                ctx.stroke();
            }
            hand(hours * Math.PI / 6, 14, 3, Theme.surfaceText.toString());
            hand(minutes * Math.PI / 30, 22, 2, Theme.primary.toString());
            ctx.fillStyle = Theme.primary.toString();
            ctx.beginPath();
            ctx.arc(0, 0, 3, 0, Math.PI * 2);
            ctx.fill();
        }
    }
}
