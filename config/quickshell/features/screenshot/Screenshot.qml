import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool open: false
    property bool recording: false

    readonly property string recPidFile: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp")
        + "/qs-screenshot-record.pid"
    readonly property string captureScript:
        Quickshell.shellPath("features/screenshot/scripts/capture.sh")

    function toggle() {
        open = !open
    }

    function close() {
        open = false
    }

    function refreshRecording() {
        aliveCheck.command = [
            "sh", "-c",
            "pid=$(cat -- " + shellQuote(root.recPidFile) + " 2>/dev/null) && kill -0 \"$pid\""
        ]
        if (aliveCheck.running)
            aliveCheck.running = false
        Qt.callLater(() => { aliveCheck.running = true })
    }

    function shellQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    function stopRecording() {
        Quickshell.execDetached(["bash", root.captureScript, "stop"])
        stopPoll.restart()
    }

    IpcHandler {
        target: "screenshot"

        function toggle(): void { root.toggle() }
        function open(): void { root.open = true }
        function close(): void { root.close() }
        function stopRecord(): void { root.stopRecording() }
    }

    Process {
        id: aliveCheck
        running: false
        onExited: function(exitCode, exitStatus) {
            root.recording = exitCode === 0
        }
    }

    Timer {
        id: stopPoll
        interval: 250
        repeat: true
        property int ticks: 0
        onTriggered: {
            root.refreshRecording()
            ticks += 1
            if (!root.recording || ticks >= 20) {
                ticks = 0
                stop()
            }
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: root.refreshRecording()
    }

    Component.onCompleted: root.refreshRecording()

    ScreenshotMenu {
        open: root.open
        recording: root.recording
        onCloseRequested: root.close()
        onActionStarted: {
            root.refreshRecording()
            kick.restart()
        }
    }

    Timer {
        id: kick
        interval: 900
        repeat: false
        onTriggered: root.refreshRecording()
    }
}
