import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

Scope {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property var screen: {
        const focused = Hyprland.focusedMonitor?.name ?? ""
        const match = Quickshell.screens.find(s => s.name === focused)
        if (match)
            return match
        return Quickshell.screens[0] ?? null
    }

    property bool open: false
    property bool armed: false
    property bool held: false

    function pulse() {
        if (!armed)
            return
        open = true
        if (!held)
            hideTimer.restart()
    }

    function toggleMute() {
        if (!sink?.audio)
            return
        sink.audio.muted = !muted
    }

    function nudge(delta) {
        if (!sink?.audio || muted)
            return
        sink.audio.volume = Math.max(0, Math.min(1.5, volume + delta))
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: root.sink?.audio ?? null

        function onVolumeChanged() {
            root.pulse()
        }

        function onMutedChanged() {
            root.pulse()
        }
    }

    Timer {
        interval: 400
        running: true
        repeat: false
        onTriggered: root.armed = true
    }

    Timer {
        id: hideTimer
        interval: 1200
        onTriggered: root.open = false
    }

    VolumeFlyer {
        output: root.screen
        open: root.open
        volume: root.volume
        muted: root.muted
        onHold: {
            root.held = true
            hideTimer.stop()
        }
        onRelease: {
            root.held = false
            if (root.open)
                hideTimer.restart()
        }
        onToggleMute: root.toggleMute()
        onNudge: root.nudge(delta)
    }
}
