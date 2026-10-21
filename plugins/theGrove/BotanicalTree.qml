import QtQuick
import qs.Common

Item {
    id: root
    property bool wilted: false
    property int stage: 0
    property bool active: false
    readonly property real leafLeanTarget: active && Theme.shortDuration > 0 ? 3 : 0
    property real leafLean: leafLeanTarget
    onLeafLeanChanged: illustration.requestPaint()
    Behavior on leafLean {
        NumberAnimation {
            duration: Math.min(200, Theme.shortDuration)
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.23, 1, 0.32, 1, 1, 1]
        }
    }

    onWiltedChanged: illustration.requestPaint()
    onStageChanged: illustration.requestPaint()

    Canvas {
        id: illustration
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const scale = Math.min(width, height) / 140;
            ctx.translate((width - 140 * scale) / 2, (height - 140 * scale) / 2);
            ctx.scale(scale, scale);

            ctx.fillStyle = "#171D1B";
            ctx.beginPath();
            ctx.ellipse(38, 128, 64, 8);
            ctx.fill();

            ctx.fillStyle = "#A57961";
            ctx.beginPath();
            ctx.moveTo(43, 98);
            ctx.lineTo(97, 98);
            ctx.lineTo(91, 125);
            ctx.quadraticCurveTo(70, 137, 49, 125);
            ctx.closePath();
            ctx.fill();
            ctx.fillStyle = "#BA8C70";
            ctx.beginPath();
            ctx.moveTo(47, 101);
            ctx.lineTo(58, 104);
            ctx.lineTo(60, 130);
            ctx.quadraticCurveTo(54, 129, 51, 125);
            ctx.closePath();
            ctx.fill();
            ctx.fillStyle = "#C1967C";
            ctx.beginPath();
            ctx.ellipse(41, 91, 58, 14);
            ctx.fill();
            ctx.fillStyle = "#34362D";
            ctx.beginPath();
            ctx.ellipse(46, 94, 48, 8);
            ctx.fill();

            ctx.strokeStyle = root.wilted ? "#96886B" : "#7DA780";
            ctx.lineWidth = 3;
            ctx.lineCap = "round";
            ctx.beginPath();
            ctx.moveTo(70, 98);
            ctx.bezierCurveTo(66, 81, 67, 57, 72, 32);
            ctx.stroke();

            const leaves = [
                [68, 82, 45, 71, 210],
                [68, 75, 89, 65, -32],
                [69, 64, 49, 52, 215],
                [70, 52, 87, 43, -35],
                [71, 41, 73, 30, -85],
                [68, 87, 91, 83, -10],
                [68, 59, 42, 40, 225],
                [70, 48, 98, 32, -30],
                [68, 76, 35, 83, 185],
                [71, 39, 57, 27, 225],
                [68, 65, 105, 58, -5],
                [70, 53, 37, 58, 190],
                [71, 42, 93, 21, -55],
                [69, 60, 55, 17, 250],
                [68, 73, 108, 81, 15]
            ];
            const colors = root.wilted ? ["#9A8A66", "#A89B76", "#7E795B"] : ["#86AD83", "#AEC79A", "#638D72"];
            const count = Math.min(leaves.length, 5 + root.stage * 2);
            for (let i = 0; i < count; i++) {
                const [sx, sy, x, y, angle] = leaves[i];
                ctx.strokeStyle = root.wilted ? "#96886B" : "#7DA780";
                ctx.lineWidth = 1.6;
                ctx.beginPath();
                ctx.moveTo(sx, sy);
                ctx.quadraticCurveTo(sx, y + 5, x, y);
                ctx.stroke();
                ctx.save();
                ctx.translate(x, y);
                ctx.rotate((angle + root.leafLean * Math.sin(i + 1) + (root.wilted ? (x < 70 ? -24 : 24) : 0)) * Math.PI / 180);
                ctx.fillStyle = colors[i % colors.length];
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.bezierCurveTo(5, -12, 20, -14, 28, -2);
                ctx.bezierCurveTo(18, 7, 7, 9, 0, 0);
                ctx.fill();
                ctx.strokeStyle = root.wilted ? "#BBB08A" : "#D2DFB9";
                ctx.lineWidth = 0.65;
                ctx.beginPath();
                ctx.moveTo(2, 0);
                ctx.quadraticCurveTo(12, -2, 23, -2);
                ctx.stroke();
                ctx.restore();
            }
        }
    }
}
