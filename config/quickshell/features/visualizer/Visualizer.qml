import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Scope {
    id: root

    required property var screen
    property bool enabled: true

    property bool mediaPlaying: false

    function updatePlaybackState() {
        mediaPlaying = Mpris.players.values.some(
            player => player && player.isPlaying
        )
    }

    CavaSpectrum {
        id: spectrum

        enabled: root.enabled
    }

    VisualizerPanel {
        screen: root.screen
        levels: spectrum.levels
        sourceAvailable: spectrum.available
        mediaPlaying: root.mediaPlaying
    }

    Timer {
        interval: 600
        running: root.enabled
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updatePlaybackState()
    }
}
