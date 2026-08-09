import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick

Scope {
    id: root

    property string rememberedPlayerDbusName: ""
    property bool ready: false
    property bool lastPlaying: false
    property string lastTitle: ""

    readonly property var players: Mpris.players.values
    readonly property var playingPlayer: players.find(player => player.isPlaying) ?? null
    readonly property var rememberedPlayer: players.find(
        player => player.dbusName === rememberedPlayerDbusName
    ) ?? null
    readonly property var selectedPlayer: playingPlayer
        ?? rememberedPlayer
        ?? players.find(player => player.canControl || player.isPlaying) ?? null
    readonly property bool isPlaying: selectedPlayer?.isPlaying ?? false
    readonly property string activeIdentity: String(selectedPlayer?.identity ?? "")
    readonly property bool available: selectedPlayer !== null
    readonly property string focusedAppClass: {
        const window = Hyprland.activeToplevel
        if (!window)
            return ""
        const ipc = window.lastIpcObject || {}
        return String(ipc.class || ipc.initialClass || window.wayland?.appId || "")
            .trim()
            .toLowerCase()
    }
    readonly property bool activeAppFocused: playerMatchesFocusedApp()

    signal updated(var model)
    signal refreshed(var model)

    CoverArtCache {
        id: coverArtCache
        source: root.selectedPlayer?.trackArtUrl ?? ""

        onResolvedSourceChanged: {
            if (root.ready)
                root.refreshed(root.playerModel(root.isPlaying ? "Playing" : "Paused"))
        }
    }

    function playerMatchesFocusedApp() {
        const focused = focusedAppClass
        if (!focused || !selectedPlayer)
            return false

        const identity = String(selectedPlayer.identity ?? "").toLowerCase()
        const dbusName = String(selectedPlayer.dbusName ?? "").toLowerCase()
        const playerKey = identity + " " + dbusName

        if (playerKey.includes("spotify"))
            return focused.includes("spotify")
        if (/firefox|mozilla/.test(playerKey))
            return /firefox|zen/.test(focused)
        if (/chromium|chrome|brave/.test(playerKey))
            return /chromium|chrome|brave/.test(focused)
        if (playerKey.includes("vlc"))
            return focused.includes("vlc")

        const normalizedIdentity = identity.replace(/[^a-z0-9]/g, "")
        const normalizedFocused = focused.replace(/[^a-z0-9]/g, "")
        return normalizedIdentity.length > 2
            && (normalizedFocused.includes(normalizedIdentity)
                || normalizedIdentity.includes(normalizedFocused))
    }

    function rememberPlayer(player) {
        const dbusName = String(player?.dbusName ?? "")
        if (!dbusName || dbusName === rememberedPlayerDbusName)
            return

        Qt.callLater(() => {
            if (root.rememberedPlayerDbusName !== dbusName)
                root.rememberedPlayerDbusName = dbusName
        })
    }

    function playerModel(stateLabel) {
        const player = selectedPlayer
        const artist = player?.trackArtist ?? ""
        return {
            stateLabel: stateLabel,
            title: String(player?.trackTitle ?? "").trim(),
            artist: Array.isArray(artist) ? artist.join(", ") : String(artist),
            artUrl: coverArtCache.resolvedSource,
            playing: player?.isPlaying ?? false,
            player: player
        }
    }

    function establishBaseline() {
        rememberPlayer(selectedPlayer)
        lastPlaying = isPlaying
        lastTitle = String(selectedPlayer?.trackTitle ?? "").trim()
    }

    function handlePlayingChanged() {
        if (!ready) {
            establishBaseline()
            initialSyncTimer.restart()
            return
        }
        if (isPlaying === lastPlaying)
            return

        lastPlaying = isPlaying
        rememberPlayer(selectedPlayer)
        const title = String(selectedPlayer?.trackTitle ?? "").trim()
        lastTitle = title
        updated(playerModel(isPlaying ? "Playing" : "Paused"))
    }

    function handleTrackChanged() {
        const title = String(selectedPlayer?.trackTitle ?? "").trim()
        if (!ready) {
            establishBaseline()
            initialSyncTimer.restart()
            return
        }
        if (!title || title === lastTitle)
            return

        lastTitle = title
        rememberPlayer(selectedPlayer)
        updated(playerModel("Now playing"))
    }

    function handleAction(action, argument) {
        const player = selectedPlayer
        if (!player)
            return

        switch (action) {
        case "previous": player.previous(); break
        case "toggle": player.togglePlaying(); break
        case "next": player.next(); break
        case "seek": {
            if (!(player.canSeek ?? false)
                    || !(player.positionSupported ?? false)
                    || !(player.lengthSupported ?? false))
                return
            const length = Number(player.length) || 0
            if (length <= 0)
                return
            const ratio = Math.max(0, Math.min(1, Number(argument) || 0))
            player.position = length * ratio
            break
        }
        }
    }

    onIsPlayingChanged: handlePlayingChanged()
    onSelectedPlayerChanged: {
        rememberPlayer(selectedPlayer)
        handleTrackChanged()
    }

    Connections {
        target: root.selectedPlayer
        function onTrackTitleChanged() { root.handleTrackChanged() }
    }

    Timer {
        id: initialSyncTimer
        interval: 500
        running: true
        onTriggered: {
            if (root.selectedPlayer) {
                root.establishBaseline()
                root.ready = true
            }
        }
    }
}
