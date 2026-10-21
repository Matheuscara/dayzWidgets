import QtQuick
import qs.Common

// Draws one rounded "island" behind the visible widgets of each DankBar
// section (left / center / right) of the bar that hosts this item.
//
// DMS 1.4.6 has no per-section background, only a full-width bar canvas or
// per-widget pills. DankBarContent names its section items "leftSection",
// "centerSection" and "rightSection"; the islands are attached to those items
// as z:-1 children, so the sections keep laying out their widgets untouched.
Item {
    id: root

    property Item anchorItem: null
    property bool active: true
    property real widgetThickness: 30
    property bool isVertical: false
    property real fillOpacity: 0.94

    readonly property var sectionNames: ["leftSection", "centerSection", "rightSection"]
    property var _islands: []
    property int _attachAttempts: 0

    width: 0
    height: 0

    function _findStack() {
        let p = anchorItem ? anchorItem.parent : null;
        while (p) {
            if (sectionNames.indexOf(p.objectName) !== -1)
                return p.parent;
            p = p.parent;
        }
        return null;
    }

    function attach() {
        if (!active)
            return;
        if (_islands.length > 0)
            return;
        const stack = _findStack();
        if (!stack) {
            if (_attachAttempts++ < 10)
                retryTimer.restart();
            return;
        }
        const created = [];
        const kids = stack.children;
        for (let i = 0; i < kids.length; i++) {
            const section = kids[i];
            if (sectionNames.indexOf(section.objectName) === -1)
                continue;
            let taken = false;
            for (let j = 0; j < section.children.length; j++) {
                if (section.children[j].objectName === "nordIsland") {
                    taken = true;
                    break;
                }
            }
            if (taken)
                continue;
            const island = islandComponent.createObject(section, {
                "section": section
            });
            if (island)
                created.push(island);
        }
        _islands = created;
    }

    function detach() {
        for (const island of _islands)
            island.destroy();
        _islands = [];
    }

    onAnchorItemChanged: Qt.callLater(attach)
    onActiveChanged: {
        if (active)
            Qt.callLater(attach);
        else
            detach();
    }

    Timer {
        id: retryTimer
        interval: 500
        repeat: false
        onTriggered: root.attach()
    }

    Component.onCompleted: Qt.callLater(attach)
    Component.onDestruction: detach()

    Connections {
        target: root.anchorItem
        function onParentChanged() {
            root.detach();
            root._attachAttempts = 0;
            Qt.callLater(root.attach);
        }
    }

    Component {
        id: islandComponent

        Rectangle {
            id: island

            property Item section: null
            property var _watched: []
            property var _connections: []
            property real padMain: Theme.spacingS
            readonly property real crossSize: root.widgetThickness + Theme.spacingS

            objectName: "nordIsland"
            z: -1
            visible: width > 0 && height > 0
            radius: Math.min(Theme.cornerRadius, crossSize / 2)
            color: Theme.withAlpha(Theme.surfaceContainer, root.fillOpacity)
            border.width: 1
            border.color: Theme.withAlpha(Theme.outlineVariant, 0.7)

            function schedule() {
                if (relayout)
                    relayout.restart();
            }

            function watch(obj, signalNames) {
                if (!obj || _watched.indexOf(obj) !== -1)
                    return;
                _watched.push(obj);
                for (const name of signalNames) {
                    if (obj[name] && typeof obj[name].connect === "function") {
                        obj[name].connect(island.schedule);
                        _connections.push({ "object": obj, "signal": name });
                    }
                }
            }

            Component.onDestruction: {
                for (const connection of _connections) {
                    try {
                        connection.object[connection.signal].disconnect(island.schedule);
                    } catch (error) {
                        // A seção observada pode ser destruída antes do seu fundo.
                    }
                }
                _connections = [];
            }

            function collectHosts(item, depth, out) {
                if (!item || depth > 5)
                    return;
                if (item === island)
                    return;
                if (item.widgetId !== undefined && item.sourceComponent !== undefined) {
                    out.push(item);
                    return;
                }
                watch(item, ["childrenChanged"]);
                const kids = item.children;
                for (let i = 0; i < kids.length; i++)
                    collectHosts(kids[i], depth + 1, out);
            }

            function recompute() {
                if (!section)
                    return;
                const hosts = [];
                collectHosts(section, 0, hosts);
                let minA = Infinity, maxA = -Infinity, centerB = 0, count = 0;
                for (const host of hosts) {
                    watch(host, ["itemChanged", "activeChanged", "opacityChanged"]);
                    watch(host.parent, ["xChanged", "yChanged", "widthChanged", "heightChanged"]);
                    const item = host.item;
                    if (!item)
                        continue;
                    watch(item, ["xChanged", "yChanged", "widthChanged", "heightChanged", "visibleChanged"]);
                    if (!host.active || host.opacity <= 0 || !item.visible || item.width <= 0 || item.height <= 0)
                        continue;
                    const pos = item.mapToItem(section, 0, 0);
                    if (root.isVertical) {
                        minA = Math.min(minA, pos.y);
                        maxA = Math.max(maxA, pos.y + item.height);
                        centerB += pos.x + item.width / 2;
                    } else {
                        minA = Math.min(minA, pos.x);
                        maxA = Math.max(maxA, pos.x + item.width);
                        centerB += pos.y + item.height / 2;
                    }
                    count++;
                }
                if (count === 0) {
                    width = 0;
                    height = 0;
                    return;
                }
                centerB /= count;
                if (root.isVertical) {
                    x = Math.round(centerB - crossSize / 2);
                    y = Math.round(minA - padMain);
                    width = crossSize;
                    height = Math.round(maxA - minA + padMain * 2);
                } else {
                    x = Math.round(minA - padMain);
                    y = Math.round(centerB - crossSize / 2);
                    width = Math.round(maxA - minA + padMain * 2);
                    height = crossSize;
                }
            }

            Timer {
                id: relayout
                interval: 16
                repeat: false
                onTriggered: island.recompute()
            }

            Connections {
                target: island.section
                function onWidthChanged() {
                    island.schedule();
                }
                function onHeightChanged() {
                    island.schedule();
                }
                function onImplicitWidthChanged() {
                    island.schedule();
                }
                function onImplicitHeightChanged() {
                    island.schedule();
                }
            }

            Connections {
                target: root
                function onWidgetThicknessChanged() {
                    island.schedule();
                }
                function onIsVerticalChanged() {
                    island.schedule();
                }
            }

            Component.onCompleted: schedule()
        }
    }
}
