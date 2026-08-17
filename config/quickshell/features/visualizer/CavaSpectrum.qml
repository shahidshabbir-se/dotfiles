import QtQuick
import Quickshell
import Quickshell.Io
import qs.shared.theme

Scope {
    id: root

    property bool enabled: true

    readonly property bool available: state.available
    readonly property var levels: state.levels
    readonly property string lastError: state.lastError

    readonly property var restartDelays: [2000, 5000, 15000, 30000, 60000]
    readonly property real maximumInputValue: 7
    readonly property real inputGain: 2.2

    function zeroLevels() {
        const values = []

        for (let i = 0; i < Constants.visualizerBarCount; i++)
            values.push(0)

        return values
    }

    function clearSpectrum() {
        state.available = false
        state.lastFrameTime = 0
        state.levels = zeroLevels()
        startupWatchdog.stop()
        staleWatchdog.stop()
    }

    function scheduleRestart(reason) {
        clearSpectrum()

        if (reason)
            state.lastError = reason

        if (!enabled)
            return

        if (!restartTimer.running) {
            const delayIndex = Math.min(
                state.restartAttempt,
                restartDelays.length - 1
            )

            restartTimer.interval = restartDelays[delayIndex]
            state.restartAttempt++
            restartTimer.start()
        }

    }

    function acceptFrame(frame) {
        const text = frame.trim()

        if (text.length === 0)
            return

        const fields = text.split(";")

        if (fields.length > 0 && fields[fields.length - 1] === "")
            fields.pop()

        if (fields.length !== Constants.visualizerBarCount)
            return

        const raw = []

        for (let i = 0; i < fields.length; i++) {
            const field = fields[i].trim()
            const value = Number(field)

            if (field.length === 0
                    || !isFinite(value)
                    || value < 0
                    || value > maximumInputValue)
                return

            const normalized = value / maximumInputValue
            raw.push(normalized)
        }

        const now = Date.now()
        const delta = state.lastFrameTime > 0
            ? Math.min(100, Math.max(8, now - state.lastFrameTime))
            : 33
        const previous = state.levels.length === Constants.visualizerBarCount
            ? state.levels
            : zeroLevels()
        const next = []

        for (let i = 0; i < raw.length; i++) {
            const left = raw[Math.max(0, i - 1)]
            const center = raw[i]
            const right = raw[Math.min(raw.length - 1, i + 1)]
            const spatial = left * 0.2 + center * 0.6 + right * 0.2
            const amplified = Math.min(1, spatial * inputGain)
            const target = Math.pow(amplified, 0.6)
            const timeConstant = target > previous[i] ? 45 : 180
            const alpha = 1 - Math.exp(-delta / timeConstant)

            next.push(previous[i] + (target - previous[i]) * alpha)
        }

        state.levels = next
        state.available = true
        state.lastFrameTime = now
        state.restartAttempt = 0
        state.lastError = ""
        startupWatchdog.stop()
        staleWatchdog.restart()

    }

    onEnabledChanged: {
        if (!enabled) {
            restartTimer.stop()
            clearSpectrum()
        }
    }

    QtObject {
        id: state

        property bool available: false
        property var levels: root.zeroLevels()
        property real lastFrameTime: 0
        property int restartAttempt: 0
        property string lastError: ""
    }

    Process {
        id: cava

        running: root.enabled && !restartTimer.running
        command: [
            "cava",
            "-p",
            Quickshell.shellPath("features/visualizer/cava.conf")
        ]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.acceptFrame(data)
        }

        stderr: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const message = data.trim()

                if (message.length > 0)
                    state.lastError = message.slice(0, 240)

            }
        }

        onStarted: startupWatchdog.restart()

        onRunningChanged: {
            if (!running && root.enabled && !restartTimer.running)
                root.scheduleRestart(state.lastError || "cava stopped")
        }

    }

    Timer {
        id: startupWatchdog

        interval: 3000
        repeat: false
        onTriggered: root.scheduleRestart("cava produced no spectrum data")
    }

    Timer {
        id: staleWatchdog

        interval: 1600
        repeat: false
        onTriggered: root.scheduleRestart("cava spectrum stream stalled")
    }

    Timer {
        id: restartTimer

        repeat: false
    }

}
