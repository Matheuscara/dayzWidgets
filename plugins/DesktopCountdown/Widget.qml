import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import qs.Services
import Quickshell
import Quickshell.Widgets

DesktopPluginComponent {
    id: root

    minWidth: 200
    minHeight: 140

    property bool initalized: false

    property string label: pluginData.label ?? "Ano novo"
    property string startDate: pluginData.startDate ?? ""
    property string endDate: pluginData.endDate ?? "2027-01-01"

    property bool showHours: pluginData.showHours ?? false
    property bool showDays: pluginData.showDays ?? true
    property bool showWeeks: pluginData.showWeeks ?? false

    property bool countMondays: pluginData.countMondays ?? false
    property bool countTuesdays: pluginData.countTuesdays ?? false
    property bool countWednesdays: pluginData.countWednesdays ?? false
    property bool countThursdays: pluginData.countThursdays ?? false
    property bool countFridays: pluginData.countFridays ?? false
    property bool countSaturdays: pluginData.countSaturdays ?? false
    property bool countSundays: pluginData.countSundays ?? false

    readonly property string backgroundImage: pluginData.backgroundImage ?? ""
    readonly property string subtitle: pluginData.subtitle ?? ""
    readonly property string eventIcon: pluginData.eventIcon ?? "event_upcoming"
    readonly property bool deadline: pluginData.deadline ?? false
    readonly property string dateCaption: pluginData.dateCaption ?? (deadline ? "Prazo" : "Até")
    property int calendarDays: 0
    readonly property bool hasPhoto: photo.status === Image.Ready
    readonly property real imageDimAmount: Math.max(0, Math.min(1, Number(pluginData.imageDimAmount ?? 0.62)))

    // Computed values
    property real days: 0
    property real weeks: 0
    property real hours: 0
    property real progress: 0

    property bool invalidEndDate: false
    property bool invalidStartDate: false

    /*
    Parses a date string in the format "YYYY-MM-DD HH:mm:ss"

    Parameters:
        str: The date string to parse

    Returns:
        The parsed Date object, or null if the string is invalid
    */
    function parseDate(str) {
        if (!str) return null;

        const parts = str.split(" ");
        const dateParts = parts[0].split("-");

        if (dateParts.length !== 3) return null;

        const y = parseInt(dateParts[0]);
        if (!Number.isFinite(y) || y < 1900 || y > 2100) return null;
        const m = parseInt(dateParts[1]) - 1;
        const d = parseInt(dateParts[2]);

        let h = 0, min = 0, s = 0;

        if (parts.length > 1) {
            const timeParts = parts[1].split(":");
            h = parseInt(timeParts[0]) || 0;
            min = parseInt(timeParts[1]) || 0;
            s = parseInt(timeParts[2]) || 0;
        }

        const parsed = new Date(y, m, d, h, min, s);
        return Number.isFinite(parsed.getTime()) && parsed.getFullYear() === y && parsed.getMonth() === m && parsed.getDate() === d ? parsed : null;
    }

    /*
    Checks if a day should be counted based on the enabled days to count

    Parameters:
        day: The day to check (0-6)

    Returns:
        True if the day should be counted, false otherwise
    */
    function shouldCountDay(day) {
        return (
            (day === 1 && root.countMondays) ||
            (day === 2 && root.countTuesdays) ||
            (day === 3 && root.countWednesdays) ||
            (day === 4 && root.countThursdays) ||
            (day === 5 && root.countFridays) ||
            (day === 6 && root.countSaturdays) ||
            (day === 0 && root.countSundays)
        );
    }

    /*
    Checks if any day filter is enabled

    Returns:
        True if any day filter is enabled, false otherwise
    */
    function anyDayFilterEnabled() {
        return root.countMondays || root.countTuesdays || root.countWednesdays ||
               root.countThursdays || root.countFridays || root.countSaturdays || root.countSundays;
    }

    /*
    Formats a date in a human-readable format

    Parameters:
        date: The date string to format

    Returns:
        The formatted date
    */
    function prettyDate(string) {
        const date = parseDate(string);

        if (!date) return null;

        return date.toLocaleDateString(Qt.locale("pt_BR"), "d MMM yyyy");
    }

    /*
    Counts the number of milliseconds between two dates. If any day filter is enabled, only hours that match the filter will be counted

    Parameters:
        from: The start date
        to: The end date

    Returns:
        The number of milliseconds
    */
    function countFilteredMs(from, to) {
        if (!anyDayFilterEnabled()) {
            return to - from;
        }
        if (to <= from) {
            return 0;
        }

        let total = 0;

        let current = new Date(from.getFullYear(), from.getMonth(), from.getDate());
        const endDay = new Date(to.getFullYear(), to.getMonth(), to.getDate());

        while (current <= endDay) {
            if (shouldCountDay(current.getDay())) {
                // start of this day
                let dayStart = new Date(current);
                let dayEnd = new Date(current);
                dayEnd.setHours(23, 59, 59, 999);

                // clamp to range
                if (dayStart < from) dayStart = from;
                if (dayEnd > to) dayEnd = to;

                if (dayEnd > dayStart) {
                    total += (dayEnd - dayStart);
                }
            }

            current.setDate(current.getDate() + 1);
        }

        return total;
    }

    /*
    Updates the values for the widget
    */
    function update() {
        const now = new Date();
        const end = parseDate(root.endDate);
        const start = parseDate(root.startDate);

        if (root.initalized && end === null) {
            root.invalidEndDate = true;
            ToastService.showError("Invalid countdown end date", "The provided end date for countdown '" + root.label + "' is invalid.");
            return;
        } else {
            root.invalidEndDate = false;
        }

        if (root.initalized && (start === null || start > end) && root.startDate !== "") {
            root.invalidStartDate = true;
            ToastService.showError("Invalid countdown start date", "The provided start date for countdown '" + root.label + "' is invalid.");
            return;
        } else {
            root.invalidStartDate = false;
        }

        // Count from start if it's available, otherwise count from now
        let countdownFrom;
        if (start && now < start) {
            countdownFrom = start;
        } else {
            countdownFrom = now;
        }

        if (end) {
            const today = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate());
            const eventDay = Date.UTC(end.getFullYear(), end.getMonth(), end.getDate());
            root.calendarDays = Math.round((eventDay - today) / 86400000);
        }
        const filteredMs = Math.max(0, countFilteredMs(countdownFrom, end));

        root.hours = Math.max(0, filteredMs / (1000 * 60 * 60));
        root.days  = root.hours / 24;
        root.weeks = root.days / 7;

        // Progress
        if (start) {
            const total = countFilteredMs(start, end);
            const elapsed = countFilteredMs(start, now);

            root.progress = total > 0
                ? Math.min(1, Math.max(0, elapsed / total))
                : 0;
        } else {
            root.progress = 0;
        }
    }

    // Update the values once the widget is loaded
    Timer {
        interval: 0
        running: true
        repeat: false
        onTriggered: {
            initalized = true
            root.update()
        }
    }

    // Then, update the values every minute
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
        onDateChanged: root.update()
    }

    // Update the values when settings change
    onLabelChanged: update()
    onStartDateChanged: update()
    onEndDateChanged: update()
    onShowHoursChanged: update()
    onShowDaysChanged: update()
    onShowWeeksChanged: update()
    onCountMondaysChanged: update()
    onCountTuesdaysChanged: update()
    onCountWednesdaysChanged: update()
    onCountThursdaysChanged: update()
    onCountFridaysChanged: update()
    onCountSaturdaysChanged: update()
    onCountSundaysChanged: update()
    onPluginDataChanged: if (initalized) update()

    HoverHandler { id: cardHover }

    ClippingRectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surface, 0.90)

        Image {
            id: photo
            anchors.fill: parent
            source: root.backgroundImage
            sourceSize.width: 1000
            sourceSize.height: 600
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            scale: cardHover.hovered && Theme.shortDuration > 0 ? 1.025 : 1
            Behavior on scale {
                NumberAnimation {
                    duration: Math.min(200, Theme.shortDuration)
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.23, 1, 0.32, 1, 1, 1]
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            visible: root.hasPhoto
            color: "#000000"
            opacity: root.imageDimAmount
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.cornerRadius
            color: "transparent"
            border.width: 1
            border.color: Theme.withAlpha(Theme.surfaceText, 0.12)
        }

        Item {
            anchors.fill: parent
            anchors.margins: 20

            DankIcon {
                id: eventIcon
                anchors.top: parent.top
                anchors.right: parent.right
                name: root.eventIcon
                size: 21
                color: root.hasPhoto ? "#FFFFFF" : Theme.primary
            }

            Column {
                anchors.left: parent.left
                anchors.right: eventIcon.left
                anchors.rightMargin: 8
                spacing: 3

                StyledText {
                    width: parent.width
                    text: root.label
                    textFormat: Text.PlainText
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: root.hasPhoto ? "#FFFFFF" : Theme.surfaceText
                    elide: Text.ElideRight
                }

                StyledText {
                    width: parent.width
                    visible: root.subtitle !== ""
                    text: root.subtitle
                    textFormat: Text.PlainText
                    font.pixelSize: 12
                    color: root.hasPhoto ? "#E4EAE7" : Theme.surfaceVariantText
                    elide: Text.ElideRight
                }
            }

            Row {
                anchors.left: parent.left
                anchors.bottom: dateLabel.top
                anchors.bottomMargin: 5
                spacing: 8

                StyledText {
                    id: numberLabel
                    text: root.invalidEndDate ? "—" : root.calendarDays < 0 ? "Encerrado" : root.calendarDays === 0 ? "Hoje" : root.showWeeks ? Math.ceil(root.weeks) : root.showHours ? Math.ceil(root.hours) : root.anyDayFilterEnabled() ? Math.ceil(root.days) : root.calendarDays
                    font.pixelSize: root.calendarDays <= 0 ? 30 : 40
                    font.weight: Font.Light
                    color: root.hasPhoto ? "#FFFFFF" : Theme.surfaceText
                }

                StyledText {
                    anchors.baseline: numberLabel.baseline
                    visible: !root.invalidEndDate && root.calendarDays > 0
                    text: root.showWeeks ? "semanas" : root.showHours ? "horas" : root.calendarDays === 1 ? "dia" : "dias"
                    font.pixelSize: 15
                    color: root.hasPhoto ? "#E4EAE7" : Theme.surfaceVariantText
                }
            }

            StyledText {
                id: dateLabel
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                text: root.invalidEndDate ? "Defina a data nas configurações" : (root.dateCaption + " · ") + root.prettyDate(root.endDate)
                font.pixelSize: 12
                color: root.hasPhoto ? "#E4EAE7" : Theme.surfaceVariantText
            }
        }
    }
}
