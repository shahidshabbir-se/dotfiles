import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import qs.configuration
import "../volume"
import "../widgets"
import "."

Scope {
    id: root

    property bool open: false
    property bool panelEffectsReady: false
    property bool colorAnimationsEnabled: false
    property var barRef: null

    readonly property var activeScreen: Quickshell.screens.find(
        screen => screen.name === Hyprland.focusedMonitor?.name
    ) ?? Quickshell.screens[0] ?? null

    readonly property var player: {
        return Mpris.players.values.find(p => p.isPlaying)
            ?? Mpris.players.values[0]
            ?? null
    }
    readonly property bool hasPlayer: player !== null
    readonly property bool playing: player?.isPlaying ?? false
    readonly property string trackTitle: player?.trackTitle ?? "Nothing playing"
    readonly property string trackArtist: player?.trackArtist ?? ""
    readonly property string artUrl: player?.trackArtUrl ?? ""
    readonly property bool isSpotify: (player?.identity ?? "").toLowerCase().includes("spotify")
    readonly property bool hasProgress: player?.positionSupported && (player?.length ?? 0) > 0
    readonly property real progressRatio: hasProgress
        ? Math.max(0, Math.min(1, player.position / player.length))
        : 0
    readonly property bool hasPlayerVolume: {
        if (!(player?.volumeSupported ?? false)) return false
        const id = (player.identity ?? "").toLowerCase()
        const bus = (player.dbusName ?? "").toLowerCase()
        const browserPattern = /chromium|firefox|chrome|brave|vivaldi|opera|edge|plasmoid/
        return !browserPattern.test(id) && !browserPattern.test(bus)
    }
    readonly property real playerVolume: hasPlayerVolume ? player.volume : 0

    property bool progressDragging: false
    property real progressDragRatio: 0
    readonly property real displayProgressRatio: progressDragging ? progressDragRatio : progressRatio

    property bool volumeDragging: false
    property real volumeDragRatio: 0
    readonly property real displayVolumeRatio: volumeDragging ? volumeDragRatio : playerVolume

    property string artColorSource: ""
    property var artColorCache: ({})
    property color artAccent: Colors.playerAccent
    property color artAccentAlt: Colors.volumeGradientEnd
    property color artAccentForeground: Colors.playerAccentForeground
    property color artPanelTint: Colors.playerPanelBackground
    property color artProgressTrack: Colors.playerProgressBg
    property color artBorder: Colors.playerPanelBorder

    signal closed()

    Behavior on artAccent { enabled: colorAnimationsEnabled; ColorAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on artAccentAlt { enabled: colorAnimationsEnabled; ColorAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on artPanelTint { enabled: colorAnimationsEnabled; ColorAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on artBorder { enabled: colorAnimationsEnabled; ColorAnimation { duration: 280; easing.type: Easing.OutCubic } }

    function formatTime(seconds) {
        if (!seconds || seconds < 0) return "0:00"
        const total = Math.floor(seconds)
        const minutes = Math.floor(total / 60)
        const secs = total % 60
        return `${minutes}:${secs.toString().padStart(2, "0")}`
    }

    function seekToRatio(ratio) {
        if (!hasProgress || !player?.canSeek) return
        const clamped = Math.max(0, Math.min(1, ratio))
        progressDragRatio = clamped
        player.position = player.length * clamped
        player.positionChanged()
    }

    function setVolumeToRatio(ratio) {
        if (!hasPlayerVolume || !player) return
        const clamped = Math.max(0, Math.min(1, ratio))
        volumeDragRatio = clamped
        player.volume = clamped
    }

    function cycleLoop() {
        if (!player?.loopSupported) return
        const next = {
            [MprisLoopState.None]: MprisLoopState.Playlist,
            [MprisLoopState.Playlist]: MprisLoopState.Track,
            [MprisLoopState.Track]: MprisLoopState.None,
        }
        player.loopState = next[player.loopState] ?? MprisLoopState.None
    }

    function close() {
        if (!open)
            return
        closed()
    }

    function parseRgb(line) {
        const parts = line.split(",").map(value => parseInt(value.trim(), 10))
        if (parts.length !== 3 || parts.some(value => isNaN(value) || value < 0 || value > 255))
            return null
        return Qt.rgba(parts[0] / 255, parts[1] / 255, parts[2] / 255, 1)
    }

    function readableOn(background) {
        const luminance = 0.299 * background.r + 0.587 * background.g + 0.114 * background.b
        return luminance > 0.58 ? "#141414" : "#f4f4f4"
    }

    function resetArtColors() {
        artAccent = Colors.playerAccent
        artAccentAlt = Colors.volumeGradientEnd
        artAccentForeground = Colors.playerAccentForeground
        artPanelTint = Colors.playerPanelBackground
        artProgressTrack = Colors.playerProgressBg
        artBorder = Colors.playerPanelBorder
        artColorSource = ""
    }

    function applyArtColors(entry) {
        artAccent = entry.accent
        artAccentAlt = entry.accentAlt
        artAccentForeground = entry.accentForeground
        artPanelTint = entry.panelTint
        artProgressTrack = entry.progressTrack
        artBorder = entry.border
    }

    function storeArtColors(url, accent, accentAlt, accentForeground, panelTint, progressTrack, border) {
        artColorCache[url] = {
            accent,
            accentAlt,
            accentForeground,
            panelTint,
            progressTrack,
            border,
        }
    }

    function refreshArtColors() {
        if (!artUrl || artUrl.length === 0) {
            resetArtColors()
            return
        }

        if (artColorCache.hasOwnProperty(artUrl)) {
            applyArtColors(artColorCache[artUrl])
            if (!colorAnimationsEnabled)
                Qt.callLater(() => colorAnimationsEnabled = true)
            return
        }

        artColorSource = artUrl
        colorExtractor.running = false
        colorExtractor.running = true
    }

    Process {
        id: colorExtractor
        running: false
        command: ["bash", Quickshell.shellPath("scripts/extract-art-colors.sh"), artColorSource]

        stdout: StdioCollector {
            onStreamFinished: {
                if (artColorSource !== artUrl)
                    return

                const lines = text.trim().split("\n").filter(line => line.length > 0)
                const accent = parseRgb(lines[0] ?? "")
                const vibrant = parseRgb(lines[1] ?? "") ?? accent
                const background = parseRgb(lines[2] ?? "")

                const primary = vibrant ?? accent
                const nextAccent = primary ?? Colors.playerAccent
                const nextAccentAlt = accent ?? primary ?? Colors.volumeGradientEnd
                const nextAccentForeground = primary ? readableOn(primary) : Colors.playerAccentForeground
                const nextPanelTint = background
                    ? Colors.withAlpha(background, 0.78)
                    : Colors.playerPanelBackground
                const nextProgressTrack = background
                    ? Colors.withAlpha(Colors.mixColors(background, "#000000", 0.35), 0.85)
                    : Colors.playerProgressBg
                const nextBorder = primary
                    ? Colors.withAlpha(Colors.mixColors(primary, "#ffffff", 0.18), 0.55)
                    : Colors.playerPanelBorder

                storeArtColors(
                    artUrl,
                    nextAccent,
                    nextAccentAlt,
                    nextAccentForeground,
                    nextPanelTint,
                    nextProgressTrack,
                    nextBorder
                )
                applyArtColors(artColorCache[artUrl])
                if (!colorAnimationsEnabled)
                    Qt.callLater(() => colorAnimationsEnabled = true)
            }
        }
    }

    onArtUrlChanged: refreshArtColors()
    onHasPlayerChanged: {
        if (hasPlayer)
            refreshArtColors()
        syncPanelEffectsReady()
    }

    Component.onCompleted: {
        refreshArtColors()
        Qt.callLater(() => {
            if (!colorAnimationsEnabled)
                colorAnimationsEnabled = true
        })
    }

    function syncPanelEffectsReady() {
        panelEffectsReady = musicPanelLoader.active && root.open
    }

    onOpenChanged: {
        if (open && musicPanelLoader.active) {
            panelEffectsReady = true
        } else if (open) {
            panelEffectsReady = false
            layoutReadyTimer.restart()
        } else {
            syncPanelEffectsReady()
        }
    }

    // Prefetch album art into Qt's image cache before the panel opens.
    Image {
        id: artPrefetch
        width: 1
        height: 1
        x: -10000
        y: -10000
        visible: false
        source: artUrl.length > 0 ? artUrl : ""
        sourceSize: Qt.size(440, 440)
        asynchronous: true
        cache: true
        mipmap: true
    }

    Timer {
        id: layoutReadyTimer
        interval: 1
        onTriggered: root.panelEffectsReady = true
    }

    Timer {
        interval: 500
        running: (open || hasPlayer) && playing
        repeat: true
        onTriggered: player?.positionChanged()
    }

    LazyLoader {
        id: musicPanelLoader
        active: root.open

        onActiveChanged: root.syncPanelEffectsReady()

        Scope {
            PopupDismissGrab {
                active: root.open
                panelWindow: panelWindow
                barRef: root.barRef
                screen: root.activeScreen
                onDismissed: root.close()
            }

            PanelWindow {
            id: panelWindow
            screen: root.activeScreen
            visible: root.open && root.activeScreen !== null
            color: "transparent"
            aboveWindows: true
            focusable: true
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell_music_popup"
            WlrLayershell.keyboardFocus: visible
                ? WlrKeyboardFocus.OnDemand
                : WlrKeyboardFocus.None

            anchors {
                top: true
                right: true
            }

            margins {
                top: BarMetrics.popupTopMargin
                right: root.activeScreen
                    ? Math.max(28, (root.activeScreen.width * 0.125))
                    : 28
            }

            implicitWidth: 316
            implicitHeight: panelColumn.implicitHeight + 44
            width: implicitWidth
            height: implicitHeight

            onVisibleChanged: if (visible) popupFocus.refocus()

            PopupFocusHost {
                id: popupFocus
                active: root.open
                anchors.fill: parent
                onEscapePressed: root.close()

                Item {
                    id: panelContent
                    anchors.fill: parent

                    readonly property int coverSide: width - 44
                    readonly property int cornerRadius: 16

                    Item {
                        id: panelBody
                        anchors.fill: parent
                                layer.enabled: root.panelEffectsReady
                                layer.smooth: true
                                layer.effect: OpacityMask {
                                    maskSource: Rectangle {
                                        width: panelBody.width
                                        height: panelBody.height
                                        radius: panelContent.cornerRadius
                                    }
                                }

                                Item {
                                    id: artBackdrop
                                    anchors.fill: parent
                                    visible: artUrl.length > 0

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: -28
                                        source: artUrl
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                        mipmap: true
                                        layer.enabled: root.panelEffectsReady
                                        layer.smooth: true
                                        layer.effect: FastBlur {
                                            radius: 72
                                        }
                                        opacity: 0.34
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: artPanelTint
                                        opacity: 0.78
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    visible: artUrl.length === 0
                                    color: Colors.playerPanelBackground
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    z: 0
                                    acceptedButtons: Qt.AllButtons
                                    onClicked: mouse => mouse.accepted = true
                                    onWheel: wheel => wheel.accepted = true
                                }

                                ColumnLayout {
                            id: panelColumn
                            z: 1
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 22
                            spacing: 18

                        Item {
                            id: coverArtContainer
                            Layout.fillWidth: true
                            Layout.preferredHeight: panelContent.coverSide
                            implicitHeight: panelContent.coverSide

                            readonly property int cornerRadius: 14

                            Image {
                                id: coverArt
                                anchors.fill: parent
                                source: artUrl.length > 0 ? artUrl : ""
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(440, 440)
                                asynchronous: true
                                cache: true
                                visible: artUrl.length > 0
                                layer.enabled: root.panelEffectsReady && artUrl.length > 0
                                layer.smooth: true
                                layer.effect: OpacityMask {
                                    maskSource: Rectangle {
                                        width: coverArtContainer.width
                                        height: coverArtContainer.height
                                        radius: coverArtContainer.cornerRadius
                                    }
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: coverArtContainer.cornerRadius
                                color: Colors.playerProgressBg
                                visible: artUrl.length === 0

                                Item {
                                    anchors.centerIn: parent
                                    width: 36
                                    height: 36

                                    Image {
                                        id: musicPlaceholderIcon
                                        anchors.fill: parent
                                        source: "../assets/svg/music.svg"
                                        sourceSize: Qt.size(48, 48)
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    ColorOverlay {
                                        anchors.fill: musicPlaceholderIcon
                                        source: musicPlaceholderIcon
                                        color: Colors.textMuted
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                MarqueeText {
                                    Layout.fillWidth: true
                                    text: trackTitle
                                    color: Colors.textPrimary
                                    font.family: "Cartograph CF"
                                    font.pixelSize: 16
                                    font.weight: Font.Medium
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: trackArtist.length > 0 ? trackArtist : (hasPlayer ? "Unknown artist" : "No active media")
                                    elide: Text.ElideRight
                                    font.family: "Cartograph CF"
                                    font.pixelSize: 12
                                    color: Colors.textSecondary
                                }
                            }

                            Rectangle {
                                visible: isSpotify
                                width: 22
                                height: 22
                                radius: 11
                                color: Colors.playerSpotify

                                Item {
                                    anchors.centerIn: parent
                                    width: 12
                                    height: 12

                                    Image {
                                        id: spotifyIcon
                                        anchors.fill: parent
                                        source: "../assets/svg/music.svg"
                                        sourceSize: Qt.size(24, 24)
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    ColorOverlay {
                                        anchors.fill: spotifyIcon
                                        source: spotifyIcon
                                        color: "#ffffff"
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: formatTime(player?.position ?? 0)
                                    font.family: "Cartograph CF"
                                    font.pixelSize: 10
                                    color: Colors.textMuted
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: formatTime(player?.length ?? 0)
                                    font.family: "Cartograph CF"
                                    font.pixelSize: 10
                                    color: Colors.textMuted
                                }
                            }

                            PlayerSliderBar {
                                Layout.fillWidth: true
                                ratio: displayProgressRatio
                                enabled: hasProgress
                                interactive: hasProgress && (player?.canSeek ?? false)
                                dragging: progressDragging
                                trackColor: artProgressTrack
                                fillColor: artAccent
                                thumbColor: artAccentForeground
                                thumbBorderColor: artAccent
                                onInteractionStarted: ratio => {
                                    progressDragging = true
                                    seekToRatio(ratio)
                                }
                                onInteractionChanged: ratio => seekToRatio(ratio)
                                onInteractionEnded: ratio => {
                                    seekToRatio(ratio)
                                    progressDragging = false
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 10

                            MusicControlButton {
                                iconSource: "../assets/svg/shuffle.svg"
                                active: player?.shuffle ?? false
                                enabled: player?.shuffleSupported ?? false
                                onClicked: if (player) player.shuffle = !player.shuffle
                            }

                            MusicControlButton {
                                iconSource: "../assets/svg/previous.svg"
                                enabled: player?.canGoPrevious ?? false
                                onClicked: player?.previous()
                            }

                            Item {
                                width: 52
                                height: 52

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 26
                                    color: artAccent
                                }

                                Item {
                                    anchors.centerIn: parent
                                    width: 22
                                    height: 22

                                    Image {
                                        id: playPauseIcon
                                        anchors.fill: parent
                                        source: playing ? "../assets/svg/pause.svg" : "../assets/svg/play.svg"
                                        sourceSize: Qt.size(32, 32)
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    ColorOverlay {
                                        anchors.fill: playPauseIcon
                                        source: playPauseIcon
                                        color: artAccentForeground
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -8
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: player?.togglePlaying()
                                }
                            }

                            MusicControlButton {
                                iconSource: "../assets/svg/next.svg"
                                enabled: player?.canGoNext ?? false
                                onClicked: player?.next()
                            }

                            MusicControlButton {
                                iconSource: "../assets/svg/repeat.svg"
                                active: (player?.loopState ?? MprisLoopState.None) !== MprisLoopState.None
                                enabled: player?.loopSupported ?? false
                                onClicked: cycleLoop()
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            visible: hasPlayerVolume

                            Item {
                                width: 16
                                height: 16

                                SpeakerIcon {
                                    anchors.fill: parent
                                    volume: displayVolumeRatio
                                }
                            }

                            PlayerSliderBar {
                                Layout.fillWidth: true
                                ratio: displayVolumeRatio
                                enabled: hasPlayerVolume
                                interactive: hasPlayerVolume
                                dragging: volumeDragging
                                trackColor: artProgressTrack
                                fillColor: artAccent
                                thumbColor: artAccentForeground
                                thumbBorderColor: artAccent
                                onInteractionStarted: ratio => {
                                    volumeDragging = true
                                    setVolumeToRatio(ratio)
                                }
                                onInteractionChanged: ratio => setVolumeToRatio(ratio)
                                onInteractionEnded: ratio => {
                                    setVolumeToRatio(ratio)
                                    volumeDragging = false
                                }
                            }

                            Text {
                                text: `${Math.round((hasPlayerVolume ? playerVolume : 0) * 100)}%`
                                font.family: "Cartograph CF"
                                font.pixelSize: 11
                                color: Colors.textMuted
                                Layout.preferredWidth: 34
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
                }
            }
        }
        }
    }

    component PlayerSliderBar: Item {
        id: sliderRoot

        property real ratio: 0
        property bool enabled: true
        property bool interactive: true
        property bool dragging: false
        property color trackColor: "#333333"
        property color fillColor: "#ffffff"
        property color thumbColor: "#ffffff"
        property color thumbBorderColor: "#cccccc"

        signal interactionStarted(real ratio)
        signal interactionChanged(real ratio)
        signal interactionEnded(real ratio)

        implicitHeight: 14

        readonly property real clampedRatio: Math.max(0, Math.min(1, ratio))

        Rectangle {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 4
            radius: 2
            color: sliderRoot.trackColor
            opacity: sliderRoot.enabled ? 1 : 0.45

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * sliderRoot.clampedRatio
                radius: parent.radius
                color: sliderRoot.fillColor

                Behavior on width {
                    enabled: !sliderRoot.dragging
                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                }
            }
        }

        Rectangle {
            id: thumb
            width: 10
            height: 10
            radius: 5
            visible: sliderRoot.enabled
            color: sliderRoot.thumbColor
            border.width: 2
            border.color: sliderRoot.thumbBorderColor
            anchors.verticalCenter: track.verticalCenter
            x: Math.max(0, Math.min(track.width - width, (track.width * sliderRoot.clampedRatio) - (width / 2)))

            Behavior on x {
                enabled: !sliderRoot.dragging
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            z: 2
            enabled: sliderRoot.interactive
            cursorShape: sliderRoot.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
            onPressed: mouse => sliderRoot.interactionStarted(clampRatio(mouse.x / track.width))
            onPositionChanged: mouse => {
                if (pressed) sliderRoot.interactionChanged(clampRatio(mouse.x / track.width))
            }
            onReleased: mouse => sliderRoot.interactionEnded(clampRatio(mouse.x / track.width))
            onCanceled: sliderRoot.interactionEnded(sliderRoot.clampedRatio)
        }

        function clampRatio(value) {
            return Math.max(0, Math.min(1, value))
        }
    }

    component MusicControlButton: Item {
        id: controlRoot

        property string iconSource
        property bool active: false
        property bool enabled: true
        signal clicked()

        width: 34
        height: 34
        opacity: enabled ? 1 : 0.35

        Rectangle {
            anchors.fill: parent
            radius: 17
            color: active ? Colors.withAlpha(root.artAccent, 0.28) : "transparent"
        }

        Item {
            anchors.centerIn: parent
            width: 18
            height: 18

            Image {
                id: controlIcon
                anchors.fill: parent
                source: controlRoot.iconSource
                sourceSize: Qt.size(28, 28)
                fillMode: Image.PreserveAspectFit
            }

            ColorOverlay {
                anchors.fill: controlIcon
                source: controlIcon
                color: active ? root.artAccent : Colors.textSecondary
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            enabled: controlRoot.enabled
            z: 10
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: controlRoot.clicked()
        }
    }
}
