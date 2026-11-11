// qmllint disable missing-property
import QtQuick
import QtTest
import "../../services/Layout.js" as Layout

TestCase {
    name: "ShellConfigLayout"

    readonly property string sections: "left,centerBegin,center,centerEnd,tray,right"

    function sectionKeys(layout) {
        let keys = [];
        for (let key in layout)
            keys.push(key);
        return keys.join(",");
    }

    function test_valid_config_keeps_all_sections_in_order() {
        const parsed = Layout.parse(JSON.stringify({
            version: 1,
            wallpaper: { directory: "~/Pictures/Wallpapers", file: "night.png" },
            bar: {
                position: "top",
                layout: {
                    left: [],
                    centerBegin: [],
                    center: [ { id: "clock", format: "ddd HH:mm" } ],
                    centerEnd: [],
                    tray: [],
                    right: []
                }
            }
        }));

        compare(parsed.ok, true);
        compare(parsed.version, 1);
        compare(parsed.position, "top");
        compare(sectionKeys(parsed.layout), sections);
        compare(parsed.layout.center.length, 1);
        compare(parsed.layout.center[0].id, "clock");
        compare(parsed.layout.center[0].format, "ddd HH:mm");
        compare(parsed.wallpaper.directory, "~/Pictures/Wallpapers");
        compare(parsed.wallpaper.file, "night.png");
    }

    function test_invalid_json_returns_errors_and_empty_layout() {
        const parsed = Layout.parse("{ not json");

        compare(parsed.ok, false);
        verify(parsed.errors.length > 0);
        compare(sectionKeys(parsed.layout), sections);
        compare(parsed.layout.center.length, 0);
    }

    function test_unsupported_version_is_an_error() {
        const parsed = Layout.parse(JSON.stringify({
            version: 2,
            bar: { position: "top", layout: { center: [ { id: "clock" } ] } }
        }));

        compare(parsed.ok, false);
        verify(parsed.errors.some(error => error.indexOf("version") >= 0));
        compare(parsed.position, "top");
    }

    function test_missing_sections_become_empty_and_are_reported() {
        const parsed = Layout.parse(JSON.stringify({
            version: 1,
            bar: { position: "top", layout: { center: [ { id: "clock" } ] } }
        }));

        compare(parsed.ok, false);
        verify(parsed.errors.some(error => error.indexOf("left") >= 0));
        compare(sectionKeys(parsed.layout), sections);
        compare(parsed.layout.left.length, 0);
        compare(parsed.layout.right.length, 0);
    }

    function test_invalid_entries_are_skipped_and_reported() {
        const parsed = Layout.parse(JSON.stringify({
            version: 1,
            bar: {
                position: "top",
                layout: {
                    left: [],
                    centerBegin: [],
                    center: [],
                    centerEnd: [],
                    tray: [],
                    right: [ { id: 7 }, { format: "HH:mm" } ]
                }
            }
        }));

        compare(parsed.ok, false);
        compare(parsed.layout.right.length, 0);
        verify(parsed.errors.some(error => error.indexOf("right") >= 0));
    }

    function test_invalid_position_falls_back_to_top() {
        const parsed = Layout.parse(JSON.stringify({
            version: 1,
            bar: {
                position: "middle",
                layout: {
                    left: [], centerBegin: [], center: [], centerEnd: [], tray: [], right: []
                }
            }
        }));

        compare(parsed.ok, false);
        compare(parsed.position, "top");
        verify(parsed.errors.some(error => error.indexOf("position") >= 0));
    }

    function test_apply_options_sets_declared_properties() {
        const widget = Qt.createQmlObject('import QtQuick; Item { property string format: "default"; property int foo: 0 }', this);
        const unknown = Layout.applyOptions(widget, { id: "clock", format: "HH:mm", foo: 3 });

        compare(widget["format"], "HH:mm");
        compare(widget["foo"], 3);
        compare(unknown.length, 0);
        widget.destroy();
    }

    function test_apply_options_reports_unknown_properties() {
        const widget = Qt.createQmlObject('import QtQuick; Item { property string format: "default" }', this);
        const unknown = Layout.applyOptions(widget, { id: "clock", format: "HH:mm", colour: "red" });

        compare(widget["format"], "HH:mm");
        compare(unknown.length, 1);
        compare(unknown[0], "colour");
        widget.destroy();
    }
}
