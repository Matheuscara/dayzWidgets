import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import "grove.js" as Grove

DesktopPluginComponent {
    id: root

    widgetWidth: 200
    widgetHeight: 220
    minWidth: 120
    minHeight: 140

    // --- Settings (settings.json / instance config) ---
    // pluginData mirrors instance config reactively, so these stay live when
    // edited from the Settings dialog (a separate pluginService instance whose
    // signals never reach us — only the instanceData/pluginData plumbing does).
    property string treeName: pluginData.treeName ?? "Grove"
    property int wateringIntervalHours: pluginData.wateringIntervalHours ?? 24
    property int minRewaterCooldownHours: pluginData.minRewaterCooldownHours ?? 4
    property bool showDayCounter: pluginData.showDayCounter ?? true
    property bool notificationsEnabled: pluginData.notificationsEnabled ?? true
    property real widgetOpacity: (pluginData.widgetOpacity ?? 100) / 100
    property bool cheaterMode: pluginData.cheaterMode ?? false
    property string cheatStage: pluginData.cheatStage ?? "sprout"

    // --- Persistent state (stored via getData/setData — instance config or settings.json) ---
    property string firstLaunchDate: ""
    property string lastWatered: ""
    property string lastNotified: ""

    onPluginDataChanged: {
        if (!_initialized || !pluginService)
            return;
        firstLaunchDate = getData("firstLaunchDate", firstLaunchDate);
        lastWatered = getData("lastWatered", lastWatered);
        lastNotified = getData("lastNotified", lastNotified);
        _lastKnownStage = getData("currentStage", _lastKnownStage);
    }

    Component.onDestruction: {
        // A plugin rescan/hot-reload can tear this instance down mid-tick or
        // mid-animation; make sure nothing fires afterward against
        // half-destroyed children (stageLoader, wateringCan, Theme, etc).
        tickTimer.stop();
        wateringAnim.stop();
    }

    property int daysAlive: Grove.daysAlive(firstLaunchDate, Date.now())
    property var currentStageInfo: cheaterMode ? Grove.STAGES[Grove.stageIndex(cheatStage)] : Grove.stageForDays(daysAlive)
    property string currentStage: currentStageInfo.key
    property bool wilted: !cheaterMode && Grove.isWilted(lastWatered, wateringIntervalHours, Date.now())
    property real hoursUntilThirsty: Grove.hoursUntilThirsty(lastWatered, wateringIntervalHours, Date.now())

    onCurrentStageChanged: {
        if (!_initialized)
            return;
        if (currentStage !== _lastKnownStage) {
            _lastKnownStage = currentStage;
            _saveState();
            if (typeof ToastService !== "undefined")
                ToastService.showInfo("Grove", treeName + " grew into a " + currentStageInfo.label + "!");
        }
    }

    property bool _initialized: false
    property string _lastKnownStage: ""

    Component.onCompleted: {
        if (!pluginService) {
            _initialized = true;
            return;
        }

        firstLaunchDate = getData("firstLaunchDate", "");
        const isFreshInstall = !firstLaunchDate;
        if (isFreshInstall) {
            firstLaunchDate = new Date().toISOString();
            setData("firstLaunchDate", firstLaunchDate);
        }

        // Fresh installs start already-thirsty rather than "just watered" —
        // otherwise the wilt display and the re-water cooldown disagree
        // about how long it's actually been.
        const defaultLastWatered = isFreshInstall ? Grove.alreadyThirstyTimestamp(wateringIntervalHours, Date.now()) : firstLaunchDate;
        lastWatered = getData("lastWatered", defaultLastWatered);
        if (isFreshInstall)
            setData("lastWatered", lastWatered);
        lastNotified = getData("lastNotified", "");
        _lastKnownStage = getData("currentStage", currentStage);

        // Compute display state immediately, but never spawn a process on
        // this very first tick — early startup (raw `dms` as a systemd
        // service) may not have a ready D-Bus/notification daemon yet, and
        // that hang was blowing past systemd's start timeout every boot.
        daysAlive = Grove.daysAlive(firstLaunchDate, Date.now());
        wilted = !cheaterMode && Grove.isWilted(lastWatered, wateringIntervalHours, Date.now());
        hoursUntilThirsty = Grove.hoursUntilThirsty(lastWatered, wateringIntervalHours, Date.now());

        _initialized = true;
    }

    function _saveState() {
        if (!pluginService)
            return;
        setData("lastWatered", lastWatered);
        setData("lastNotified", lastNotified);
        setData("currentStage", currentStage);
    }

    function water() {
        if (Grove.hoursSinceWatered(lastWatered, Date.now()) < minRewaterCooldownHours) {
            if (typeof ToastService !== "undefined")
                ToastService.showInfo(treeName, "Ainda está hidratada; aguarde o intervalo entre regas.");
            return;
        }
        lastWatered = new Date().toISOString();
        wilted = false;
        hoursUntilThirsty = wateringIntervalHours;
        _saveState();
        if (Theme.shortDuration > 0)
            wateringAnim.restart();
    }

    Timer {
        id: tickTimer
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            root.daysAlive = Grove.daysAlive(root.firstLaunchDate, Date.now());
            root.wilted = !root.cheaterMode && Grove.isWilted(root.lastWatered, root.wateringIntervalHours, Date.now());
            root.hoursUntilThirsty = Grove.hoursUntilThirsty(root.lastWatered, root.wateringIntervalHours, Date.now());

            if (!root._initialized || !root.notificationsEnabled || root.cheaterMode)
                return;

            if (Grove.shouldNotifyThirsty(root.lastWatered, root.lastNotified, root.wateringIntervalHours, 6, Date.now())) {
                root.lastNotified = new Date().toISOString();
                root._saveState();
                Quickshell.execDetached(["notify-send", "🌱 Grove", root.treeName + " is thirsty"]);
            }
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surface, 0.90)
        border.width: 1
        border.color: Theme.withAlpha(Theme.surfaceText, 0.09)
        opacity: 1
    }

    HoverHandler { id: groveHover }

    Loader {
        id: stageLoader
        x: 8
        y: 12
        width: 120
        height: parent.height - 24
        opacity: root.widgetOpacity
        source: "BotanicalTree.qml"
    }

    Connections {
        target: stageLoader
        function onLoaded() {
            stageLoader.item.wilted = Qt.binding(() => root.wilted);
            stageLoader.item.stage = Qt.binding(() => Grove.stageIndex(root.currentStage));
            stageLoader.item.active = Qt.binding(() => groveHover.hovered);
        }
    }

    Connections {
        target: root
        function onWiltedChanged() {
            if (stageLoader.item)
                stageLoader.item.wilted = root.wilted;
        }
    }

    // --- Watering animation: a can swoops in, tips over, pours, swoops away ---
    Item {
        id: wateringCan
        width: 30
        height: 20
        x: stageLoader.x + stageLoader.width * 0.58
        y: stageLoader.y - 4
        transformOrigin: Item.BottomRight
        rotation: -16
        opacity: 0
        scale: 0.5

        Rectangle {
            id: canBody
            width: parent.width * 0.64
            height: parent.height * 0.85
            radius: 4
            color: Theme.primary
            anchors.left: parent.left
            anchors.bottom: parent.bottom
        }

        Rectangle {
            id: canSpout
            width: parent.width * 0.46
            height: 5
            radius: 2.5
            color: Theme.primary
            anchors.right: parent.right
            anchors.bottom: canBody.bottom
            anchors.bottomMargin: canBody.height * 0.6
            transformOrigin: Item.Left
            rotation: -20
        }
    }

    Rectangle {
        id: drop1
        width: 5
        height: 6
        radius: 2.5
        color: Qt.lighter(Theme.primary, 1.35)
        opacity: 0
    }

    Rectangle {
        id: drop2
        width: 5
        height: 6
        radius: 2.5
        color: Qt.lighter(Theme.primary, 1.35)
        opacity: 0
    }

    Rectangle {
        id: drop3
        width: 5
        height: 6
        radius: 2.5
        color: Qt.lighter(Theme.primary, 1.35)
        opacity: 0
    }

    // Every step lives inside this one group so restart() can never leave a
    // stray animation running independently on the drops or the can.
    SequentialAnimation {
        id: wateringAnim

        ScriptAction { script: { wateringCan.opacity = 0; wateringCan.scale = 0.5; wateringCan.rotation = -16; drop1.opacity = 0; drop2.opacity = 0; drop3.opacity = 0; } }
        ParallelAnimation {
            NumberAnimation { target: wateringCan; property: "opacity"; to: 1; duration: 150 }
            NumberAnimation { target: wateringCan; property: "scale"; to: 1; duration: 150; easing.type: Easing.OutBack }
        }
        NumberAnimation { target: wateringCan; property: "rotation"; to: -64; duration: 220; easing.type: Easing.OutQuad }
        ParallelAnimation {
            SequentialAnimation {
                ScriptAction { script: { drop1.x = wateringCan.x + wateringCan.width * 0.86; drop1.y = wateringCan.y + wateringCan.height * 0.75; drop1.opacity = 0.9; } }
                ParallelAnimation {
                    NumberAnimation { target: drop1; property: "y"; to: stageLoader.y + stageLoader.height * 0.28; duration: 260; easing.type: Easing.InQuad }
                    NumberAnimation { target: drop1; property: "opacity"; to: 0; duration: 260 }
                }
            }
            SequentialAnimation {
                PauseAnimation { duration: 90 }
                ScriptAction { script: { drop2.x = wateringCan.x + wateringCan.width * 0.7; drop2.y = wateringCan.y + wateringCan.height * 0.75; drop2.opacity = 0.9; } }
                ParallelAnimation {
                    NumberAnimation { target: drop2; property: "y"; to: stageLoader.y + stageLoader.height * 0.32; duration: 260; easing.type: Easing.InQuad }
                    NumberAnimation { target: drop2; property: "opacity"; to: 0; duration: 260 }
                }
            }
            SequentialAnimation {
                PauseAnimation { duration: 180 }
                ScriptAction { script: { drop3.x = wateringCan.x + wateringCan.width * 0.78; drop3.y = wateringCan.y + wateringCan.height * 0.75; drop3.opacity = 0.9; } }
                ParallelAnimation {
                    NumberAnimation { target: drop3; property: "y"; to: stageLoader.y + stageLoader.height * 0.3; duration: 260; easing.type: Easing.InQuad }
                    NumberAnimation { target: drop3; property: "opacity"; to: 0; duration: 260 }
                }
            }
            SequentialAnimation {
                PauseAnimation { duration: 120 }
                NumberAnimation { target: stageLoader; property: "scale"; to: 1.06; duration: 160; easing.type: Easing.OutQuad }
                NumberAnimation { target: stageLoader; property: "scale"; to: 1.0; duration: 220; easing.type: Easing.OutBack }
            }
            PauseAnimation { duration: 460 }
        }
        NumberAnimation { target: wateringCan; property: "rotation"; to: -16; duration: 200; easing.type: Easing.InQuad }
        ParallelAnimation {
            NumberAnimation { target: wateringCan; property: "opacity"; to: 0; duration: 160 }
            NumberAnimation { target: wateringCan; property: "scale"; to: 0.5; duration: 160 }
        }
    }

    Column {
        x: 144
        width: parent.width - 164
        anchors.verticalCenter: parent.verticalCenter
        spacing: 7

        Text {
            width: parent.width
            text: root.treeName
            textFormat: Text.PlainText
            font.family: SettingsData.fontFamily
            font.pixelSize: 14
            font.weight: Font.Medium
            color: Theme.surfaceText
            elide: Text.ElideRight
        }

        Text {
            visible: root.showDayCounter
            text: ["Broto", "Muda", "Árvore jovem", "Árvore adulta", "Árvore antiga", "Árvore anciã"][Grove.stageIndex(root.currentStage)] + " · " + root.daysAlive + (root.daysAlive === 1 ? " dia" : " dias")
            font.family: SettingsData.fontFamily
            font.pixelSize: 12
            color: Theme.surfaceVariantText
        }

        Row {
            spacing: 5
            DankIcon {
                name: "water_drop"
                size: 14
                color: root.wilted ? Theme.warning : "#A2C7D1"
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: root.wilted ? "Clique para regar" : "Regar em " + Math.max(1, Math.ceil(root.hoursUntilThirsty)) + " h"
                font.family: SettingsData.fontFamily
                font.pixelSize: 12
                color: root.wilted ? Theme.warning : Theme.surfaceVariantText
            }
        }

        Rectangle {
            width: parent.width
            height: 4
            radius: 2
            color: Theme.surfaceContainerHighest
            Rectangle {
                height: parent.height
                radius: parent.radius
                color: root.wilted ? Theme.warning : "#A2C7D1"
                width: parent.width * Math.max(0, Math.min(1, root.hoursUntilThirsty / root.wateringIntervalHours))
                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.water()
    }
}
