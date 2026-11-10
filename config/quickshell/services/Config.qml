pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "Layout.js" as Layout

Item {
    id: root

    readonly property string filePath: Quickshell.shellPath("shell.json")

    property string rawText: ""
    property var parsed: Layout.parse("")

    readonly property var layout: parsed.layout
    readonly property string position: parsed.position
    readonly property int version: parsed.version
    readonly property var wallpaper: parsed.wallpaper
    readonly property var errors: parsed.errors
    readonly property bool valid: parsed.ok

    function applyOptions(target, entry, onUnknown) {
        return Layout.applyOptions(target, entry, onUnknown);
    }

    function reload() {
        var text = fileView.text();
        var next = Layout.parse(text);

        root.rawText = text;
        root.parsed = next;

        for (var i = 0; i < next.errors.length; i++)
            console.error("shell.json: " + next.errors[i]);
    }

    FileView {
        id: fileView

        path: root.filePath
        watchChanges: true
        preload: true
        printErrors: false

        onLoaded: root.reload()
        onFileChanged: {
            root.reload();
            reread.restart();
        }
        onLoadFailed: function (error) {
            console.error("shell.json: cannot read " + root.filePath + " (" + error + ")");
            root.rawText = "";
            root.parsed = Layout.parse("");
        }
    }

    // Some editors replace the file instead of writing in place. A second read
    // a moment later catches the replacement even if the first one raced it.
    Timer {
        id: reread

        interval: 50
        onTriggered: root.reload()
    }
}
