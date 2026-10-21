.pragma library

// Pure logic for theGrove. No QML imports, no side effects — testable in isolation.

var STAGES = [
    { key: "sprout", label: "Sprout", minDays: 0 },
    { key: "sapling", label: "Sapling", minDays: 3 },
    { key: "youngTree", label: "Young Tree", minDays: 7 },
    { key: "mature", label: "Mature", minDays: 14 },
    { key: "ancient", label: "Ancient", minDays: 30 },
    { key: "elder", label: "Elder", minDays: 90 }
];

function daysAlive(firstLaunchIso, nowMs) {
    if (!firstLaunchIso)
        return 0;
    var first = Date.parse(firstLaunchIso);
    if (isNaN(first))
        return 0;
    var now = nowMs === undefined ? Date.now() : nowMs;
    var diff = now - first;
    if (diff <= 0)
        return 0;
    return Math.floor(diff / 86400000);
}

function stageForDays(days) {
    var current = STAGES[0];
    for (var i = 0; i < STAGES.length; i++) {
        if (days >= STAGES[i].minDays)
            current = STAGES[i];
    }
    return current;
}

function stageIndex(stageKey) {
    for (var i = 0; i < STAGES.length; i++) {
        if (STAGES[i].key === stageKey)
            return i;
    }
    return 0;
}

function isWilted(lastWateredIso, intervalHours, nowMs) {
    if (!lastWateredIso)
        return false;
    var lastWatered = Date.parse(lastWateredIso);
    if (isNaN(lastWatered))
        return false;
    var now = nowMs === undefined ? Date.now() : nowMs;
    var intervalMs = intervalHours * 3600000;
    return (now - lastWatered) > intervalMs;
}

// Fires at most once per cooldown window, only while actually wilted.
function shouldNotifyThirsty(lastWateredIso, lastNotifiedIso, intervalHours, cooldownHours, nowMs) {
    var now = nowMs === undefined ? Date.now() : nowMs;
    if (!isWilted(lastWateredIso, intervalHours, now))
        return false;
    if (!lastNotifiedIso)
        return true;
    var lastNotified = Date.parse(lastNotifiedIso);
    if (isNaN(lastNotified))
        return true;
    var cooldownMs = cooldownHours * 3600000;
    return (now - lastNotified) > cooldownMs;
}

function formatDayCount(days) {
    return days === 1 ? "1 day" : days + " days";
}

// Hours remaining before the tree wilts, clamped to 0 (never negative).
function hoursUntilThirsty(lastWateredIso, intervalHours, nowMs) {
    if (!lastWateredIso)
        return 0;
    var lastWatered = Date.parse(lastWateredIso);
    if (isNaN(lastWatered))
        return 0;
    var now = nowMs === undefined ? Date.now() : nowMs;
    var remainingMs = intervalHours * 3600000 - (now - lastWatered);
    return Math.max(0, remainingMs / 3600000);
}

// Hours elapsed since the last watering (0 if never watered / bad date).
function hoursSinceWatered(lastWateredIso, nowMs) {
    if (!lastWateredIso)
        return 0;
    var lastWatered = Date.parse(lastWateredIso);
    if (isNaN(lastWatered))
        return 0;
    var now = nowMs === undefined ? Date.now() : nowMs;
    return Math.max(0, (now - lastWatered) / 3600000);
}

// A lastWatered timestamp already past the interval, so a fresh tree (or one
// that's just been reset) starts genuinely thirsty instead of claiming it was
// just watered.
function alreadyThirstyTimestamp(intervalHours, nowMs) {
    var now = nowMs === undefined ? Date.now() : nowMs;
    return new Date(now - intervalHours * 3600000 - 60000).toISOString();
}

// Shifts an ISO timestamp backward by the given number of hours, simulating
// time having passed. Falls back to "now" if the timestamp is missing/invalid.
function shiftIsoByHours(iso, hours, nowMs) {
    var now = nowMs === undefined ? Date.now() : nowMs;
    var base = iso ? Date.parse(iso) : NaN;
    if (isNaN(base))
        base = now;
    return new Date(base - hours * 3600000).toISOString();
}

function formatCountdown(hoursRemaining) {
    if (hoursRemaining <= 0)
        return "Thirsty";
    var totalMinutes = Math.round(hoursRemaining * 60);
    var h = Math.floor(totalMinutes / 60);
    var m = totalMinutes % 60;
    if (h <= 0)
        return m + "m until water";
    return h + "h " + m + "m until water";
}
