import Quickshell
import QtQuick

Scope {
    id: root

    readonly property var applications: DesktopEntries.applications.values

    function launch(entry) {
        if (entry)
            entry.execute()
    }
}
