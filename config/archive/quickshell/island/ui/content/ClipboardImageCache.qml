import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property string entryId: ""
    property string source: ""

    visible: false
    width: 0
    height: 0

    function resolve() {
        cacheProcess.running = false
        source = ""
        if (!entryId)
            return

        cacheProcess.exec([
            "sh",
            Quickshell.shellPath("scripts/cache-clipboard-image.sh"),
            entryId
        ])
    }

    onEntryIdChanged: resolve()
    Component.onCompleted: resolve()

    Process {
        id: cacheProcess

        stdout: SplitParser {
            onRead: line => {
                const path = line.trim()
                if (path)
                    root.source = path
            }
        }
    }
}
