import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: root

    readonly property var player: {
        let fallback = null

        for (let i = 0; i < Mpris.players.values.length; i++) {
            const candidate = Mpris.players.values[i]

            if (candidate.isPlaying)
                return candidate

            if (!fallback || candidate.identity.toLowerCase().includes("spotify"))
                fallback = candidate
        }

        return fallback
    }

    readonly property bool hasPlayer: player !== null
    readonly property bool hasCurrentPlayback: hasPlayer
        && player.playbackState !== MprisPlaybackState.Stopped
    readonly property bool isPlaying: hasPlayer && player.isPlaying

    readonly property string title: hasPlayer
        ? (player.trackTitle || "Unknown title")
        : "Nothing playing"
    readonly property string artist: hasPlayer
        ? (player.trackArtist || "Unknown artist")
        : "Start a player to see media here"
    readonly property url fallbackArtwork: Qt.resolvedUrl(
        "assets/artwork/music-fallback.svg"
    )
    readonly property url artworkSource: hasPlayer && player.trackArtUrl
        ? player.trackArtUrl
        : fallbackArtwork

    readonly property real positionSeconds: hasPlayer ? player.position : 0
    readonly property real durationSeconds: hasPlayer && player.lengthSupported
        ? player.length
        : 0
    readonly property real progress: durationSeconds > 0
        ? Math.min(1, Math.max(0, positionSeconds / durationSeconds))
        : 0

    readonly property bool canSeek: hasPlayer
        && player.canSeek
        && player.positionSupported
        && durationSeconds > 0
    readonly property bool canGoPrevious: hasPlayer && player.canGoPrevious
    readonly property bool canTogglePlaying: hasPlayer
        && player.canTogglePlaying
    readonly property bool canGoNext: hasPlayer && player.canGoNext

    readonly property bool shuffleSupported: hasPlayer
        && player.shuffleSupported
    readonly property bool canToggleShuffle: shuffleSupported
        && player.canControl
    readonly property bool shuffleActive: shuffleSupported && player.shuffle

    readonly property bool loopSupported: hasPlayer && player.loopSupported
    readonly property bool canToggleLoop: loopSupported && player.canControl
    readonly property bool loopActive: loopSupported
        && player.loopState !== MprisLoopState.None

    readonly property bool canSetVolume: hasPlayer
        && player.canControl
        && player.volumeSupported
    readonly property real volume: hasPlayer && player.volumeSupported
        ? Math.min(1, Math.max(0, player.volume))
        : 0

    function seekTo(normalizedPosition) {
        if (!canSeek)
            return

        player.position = Math.min(1, Math.max(0, normalizedPosition))
            * durationSeconds
    }

    function goPrevious() {
        if (canGoPrevious)
            player.previous()
    }

    function togglePlaying() {
        if (canTogglePlaying)
            player.togglePlaying()
    }

    function goNext() {
        if (canGoNext)
            player.next()
    }

    function toggleShuffle() {
        if (canToggleShuffle)
            player.shuffle = !player.shuffle
    }

    function toggleLoop() {
        if (!canToggleLoop)
            return

        player.loopState = player.loopState === MprisLoopState.None
            ? MprisLoopState.Playlist
            : MprisLoopState.None
    }

    function setVolume(normalizedVolume) {
        if (canSetVolume)
            player.volume = Math.min(1, Math.max(0, normalizedVolume))
    }

    property Timer positionRefreshTimer: Timer {
        interval: 500
        repeat: true
        running: root.isPlaying

        onTriggered: root.player.positionChanged()
    }
}
