import QtQuick
import qs.plugins.clock as ClockPlugin

// The static plugin registry from ADR 0003: adding a plugin means a folder and
// one entry here. There is no discovery and no manifest.
QtObject {
    id: root

    readonly property Component clockEntry: Component {
        ClockPlugin.Clock {}
    }

    readonly property var entries: ({
        "clock": clockEntry
    })

    function entryFor(id) {
        if (typeof id !== "string" || id.length === 0)
            return null;
        var component = entries[id];
        return component === undefined ? null : component;
    }
}
