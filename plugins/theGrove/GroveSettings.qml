import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import "grove.js" as Grove

PluginSettings {
    id: root
    pluginId: "theGrove"

    StringSetting {
        settingKey: "treeName"
        label: I18n.tr("Tree Name")
        description: I18n.tr("Flavor label shown on hover and in notifications")
        placeholder: "Grove"
        defaultValue: "Grove"
    }

    SliderSetting {
        settingKey: "wateringIntervalHours"
        label: I18n.tr("Watering Interval")
        description: I18n.tr("How long before the tree wilts without a click")
        defaultValue: 24
        minimum: 6
        maximum: 72
        unit: "h"
    }

    SliderSetting {
        settingKey: "minRewaterCooldownHours"
        label: I18n.tr("Earliest Watering")
        description: I18n.tr("Minimum time since last watering before clicking does anything — stops spam-clicking from constantly refilling the countdown")
        defaultValue: 4
        minimum: 1
        maximum: 24
        unit: "h"
    }

    ToggleSetting {
        settingKey: "showDayCounter"
        label: I18n.tr("Show Day Counter")
        description: I18n.tr("Label below the widget showing days alive")
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "notificationsEnabled"
        label: I18n.tr("Watering Reminders")
        description: I18n.tr("Notify via notify-send when the tree gets thirsty")
        defaultValue: true
    }

    SliderSetting {
        settingKey: "widgetOpacity"
        label: I18n.tr("Widget Opacity")
        description: I18n.tr("Ghosted overlay support for wallpaper integration")
        defaultValue: 100
        minimum: 20
        maximum: 100
        unit: "%"
    }

    ToggleSetting {
        settingKey: "cheaterMode"
        label: I18n.tr("Cheater Mode")
        description: I18n.tr("Override the displayed growth stage (yes, this is cheating)")
        defaultValue: false
    }

    SelectionSetting {
        settingKey: "cheatStage"
        label: I18n.tr("Forced Stage")
        description: I18n.tr("Only applies while Cheater Mode is on")
        options: [
            { label: I18n.tr("Sprout"), value: "sprout" },
            { label: I18n.tr("Sapling"), value: "sapling" },
            { label: I18n.tr("Young Tree"), value: "youngTree" },
            { label: I18n.tr("Mature"), value: "mature" },
            { label: I18n.tr("Ancient"), value: "ancient" },
            { label: I18n.tr("Elder"), value: "elder" }
        ]
        defaultValue: "sprout"
    }

    DankButton {
        text: I18n.tr("Fast-Forward 1 Day")
        buttonHeight: 36
        onClicked: {
            const firstLaunchDate = root.loadValue("firstLaunchDate", "");
            const lastWatered = root.loadValue("lastWatered", "");
            root.saveValue("firstLaunchDate", Grove.shiftIsoByHours(firstLaunchDate, 24, Date.now()));
            root.saveValue("lastWatered", Grove.shiftIsoByHours(lastWatered, 24, Date.now()));
        }
    }

    Item {
        width: parent ? parent.width : 0
        height: resetColumn.implicitHeight

        Column {
            id: resetColumn
            width: parent.width
            spacing: Theme.spacingS

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.outline
                opacity: 0.3
            }

            StyledText {
                text: I18n.tr("Reset Grove")
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            StyledText {
                text: I18n.tr("Resets growth and watering — the tree starts over as a sprout, right now.")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                width: parent.width
                wrapMode: Text.WordWrap
            }

            DankButton {
                text: I18n.tr("Reset data")
                backgroundColor: Theme.error
                textColor: Theme.surfaceContainer
                buttonHeight: 36
                onClicked: {
                    const now = new Date().toISOString();
                    const intervalHours = root.loadValue("wateringIntervalHours", 24);
                    root.saveValue("firstLaunchDate", now);
                    // Already-thirsty, not "just watered" — matches the
                    // fresh-install default so wilt state and the re-water
                    // cooldown never disagree.
                    root.saveValue("lastWatered", Grove.alreadyThirstyTimestamp(intervalHours, Date.now()));
                    root.saveValue("lastNotified", "");
                    root.saveValue("currentStage", "sprout");
                }
            }
        }
    }
}
