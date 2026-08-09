import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property string source: ""
    property string resolvedSource: ""
    property string requestedSource: ""

    visible: false
    width: 0
    height: 0

    function resolve() {
        cacheProcess.running = false
        requestedSource = source

        if (!source) {
            resolvedSource = ""
            return
        }

        if (source.startsWith("file://")
                || source.startsWith("qrc:")
                || source.startsWith("image://")
                || source.startsWith("/")) {
            resolvedSource = source.startsWith("/") ? "file://" + source : source
            return
        }

        resolvedSource = ""
        cacheProcess.command = [
            "sh",
            Quickshell.shellPath("scripts/cache-cover-art.sh"),
            source
        ]
        cacheProcess.running = true
    }

    onSourceChanged: resolve()
    Component.onCompleted: resolve()

    Process {
        id: cacheProcess

        stdout: SplitParser {
            onRead: line => {
                const cachedPath = line.trim()
                if (cachedPath && root.source === root.requestedSource)
                    root.resolvedSource = cachedPath
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0 && root.source === root.requestedSource)
                root.resolvedSource = root.source
        }
    }
}
