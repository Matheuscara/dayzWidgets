import QtQuick
import QtTest
import "../../plugins/NordHub/HubConfig.js" as Hub
import "../../plugins/QuickShortcuts/ShortcutConfig.js" as Shortcuts
import "../../plugins/AnimeGallery/GalleryData.js" as Gallery

TestCase {
    name: "PortableConfiguration"

    function test_native_defaults_have_no_personal_instances() {
        const config = Hub.readTools({});
        compare(config.error, "");
        compare(config.items.length, 3);
        verify(config.items.every(tool => tool.kind === "native" && !tool.target));
    }

    function test_custom_instance_ids_and_argv_are_preserved() {
        const tool = {name: "Meu relógio", kind: "desktop", target: "clock-42", ipc: ["desktopWidget", "toggleEnabled", "clock-42"]};
        const config = Hub.readTools({toolsJson: JSON.stringify([tool])});
        compare(config.error, "");
        compare(config.items[0].target, "clock-42");
        compare(config.items[0].ipc[2], "clock-42");
        compare(config.items[0].category, "util");
    }

    function test_invalid_config_never_falls_back_to_launchable_items() {
        const inputs = [{toolsJson: "{"}, {tools: [{name: "Bad", kind: "app", command: "sh -c true"}]}, {tools: [{name: "Bad", kind: "desktop", ipc: ["a"]}]}];
        for (const input of inputs) {
            const config = Hub.readTools(input);
            compare(config.items.length, 0);
            verify(config.error.length > 0);
        }
        compare(Hub.readTools({tools: []}).items.length, 0);
    }

    function test_shortcuts_default_to_native_features_in_both_orientations() {
        const config = Shortcuts.read({}, "/tmp/test home");
        compare(config.error, "");
        compare(config.items.length, 3);
        compare(config.items[0].url, "file:///tmp/test%20home");
        verify(config.items.every(item => !item.command || item.command[0] === "dms"));
    }

    function test_shortcuts_keep_argument_boundaries_and_reject_shell_strings() {
        const command = ["my-editor", "/tmp/a b", "$(touch marker)"];
        const result = Shortcuts.read({shortcutsJson: JSON.stringify([{name: "Editor", icon: "code", command: command}])}, "/tmp");
        compare(result.error, "");
        compare(result.items[0].command, command);
        verify(Shortcuts.read({shortcuts: [{name: "Bad", icon: "code", command: "sh -c true"}]}, "/tmp").error.length > 0);
        verify(Shortcuts.read({shortcutsJson: "null"}, "/tmp").error.length > 0);
    }

    function test_gallery_rejects_parent_paths_but_handles_unusual_filenames() {
        const manifest = JSON.stringify({images: [null, {file: "../outside.png"}, {file: "/outside.png"}, {file: "photos/../../outside.png"}, {file: "photos/a #1.png"}]});
        const images = Gallery.parseManifest(manifest);
        compare(images.length, 1);
        compare(images[0].file, "photos/a #1.png");
        compare(images[0].collection, "Minha coleção");
        compare(Gallery.fileUrl("/tmp/photos/a #1.png"), "file:///tmp/photos/a%20%231.png");
    }

    function test_gallery_reports_invalid_manifest() {
        let caught = false;
        try { Gallery.parseManifest('{"images":null}'); } catch (_) { caught = true; }
        verify(caught);
    }
}
