import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Shapes
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.features.weather as WeatherFeature
import qs.shared.theme

// v2/v3 pattern: one PanelWindow per Quickshell.screens entry.
// Soft rebind of a single window dies on placeholder after sleep; Variants
// remounts when real outputs appear. If Qt stays on placeholder, quit so
// systemd + launch.sh retry once Hyprland/Qt have settled.
Scope {
    id: root

    property int orientation: Qt.Horizontal
    property int notificationCount: 0
    property bool notificationCenterOpen: false
    property bool doNotDisturb: false
    property bool recording: false
    // The audio panel is its own feature-owned window; the bar only tracks
    // whether it is up (for the popup/hide logic) and owns its button.
    property bool audioOpen: false
    // Button glyph state, owned by the audio feature.
    property string audioIcon: "󰕾"
    property bool audioMuted: false
    // Same for the weather feature, which owns its own window too.
    property bool weatherOpen: false
    property string weatherGlyph: ""
    readonly property bool vertical: orientation === Qt.Vertical

    property var primaryWindow: null
    readonly property var screen: primaryWindow ? primaryWindow.screen : null
    readonly property int implicitWidth: primaryWindow
        ? primaryWindow.implicitWidth
        : (vertical ? Constants.barVerticalWidth : Constants.barMaxWidth)

    signal notificationsClicked()
    signal popupOpened()
    signal recordingStopClicked()
    // The audio feature owns its own window, so the bar can only ask for it to
    // open or close. audioOpen is wired back from the feature.
    signal audioToggleRequested()
    signal audioCloseRequested()
    signal weatherToggleRequested()
    signal weatherCloseRequested()

    function isUsableScreen(s) {
        if (!s)
            return false
        const n = String(s.name || "")
        return n.length > 0 && n !== "FALLBACK" && n.indexOf("placeholder") < 0
    }

    function registerWindow(window) {
        if (!window || !isUsableScreen(window.screen))
            return
        if (primaryWindow === window)
            return
        primaryWindow = window
    }

    function unregisterWindow(window) {
        if (primaryWindow !== window)
            return

        primaryWindow = null
        const screens = Quickshell.screens
        for (let i = 0; i < screens.length; i++) {
            // Primary is re-picked by the next usable window's onCompleted /
            // onScreenChanged; nothing else to do here.
        }
    }

    function closePopups() {
        if (primaryWindow)
            primaryWindow.closePopups()
        root.audioCloseRequested()
        root.weatherCloseRequested()
    }

    function toggleNetwork() {
        if (primaryWindow)
            primaryWindow.toggleNetwork()
    }

    function toggleBluetooth() {
        if (primaryWindow)
            primaryWindow.toggleBluetooth()
    }

    function toggleMusic() {
        if (primaryWindow)
            primaryWindow.toggleMusic()
    }

    function toggleCalendar() {
        if (primaryWindow)
            primaryWindow.toggleCalendar()
    }

    IpcHandler {
        target: "bar"

        function toggleNetwork(): void { root.toggleNetwork() }
        function toggleBluetooth(): void { root.toggleBluetooth() }
        function toggleMusic(): void { root.toggleMusic() }
        function toggleAudio(): void { root.audioToggleRequested() }
        function toggleCalendar(): void { root.toggleCalendar() }
        function toggleWeather(): void { root.weatherToggleRequested() }
        function closePopups(): void { root.closePopups() }
    }

    // Qt can report "no outputs" forever after DPMS even when Hyprland has DP-4.
    // Exit so Restart=always + launch.sh wait recovers.
    Timer {
        id: stuckQuit
        interval: 2000
        running: true
        repeat: true
        property int stuckTicks: 0

        onTriggered: {
            if (root.isUsableScreen(root.screen)) {
                stuckTicks = 0
                return
            }

            stuckTicks += 1
            if (stuckTicks >= 5)
                Qt.quit()
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData

            property int orientation: root.orientation
            property int notificationCount: root.notificationCount
            property bool notificationCenterOpen: root.notificationCenterOpen
            property bool doNotDisturb: root.doNotDisturb
            property bool recording: root.recording
            property bool audioOpen: root.audioOpen
            property bool weatherOpen: root.weatherOpen
            readonly property bool vertical: orientation === Qt.Vertical

            // macOS-style: hide over fullscreen, show when the cursor hits the edge.
            // hyprctl activeworkspace is the visible workspace; QML hasFullscreen
            // and monitor.activeWorkspace stay stale across switches.
            property bool fullscreen: false
            property bool fullscreenRevealed: false

            // Middle of the visible centre cluster — the date and time text
            // through to the weather button — in window coordinates. Centring on
            // the bar, or on the clock item (which is wider than its text), both
            // put the popup left of the middle of what the user actually sees.
            readonly property real centerClusterCenterX: bar.vertical
                ? width / 2
                : (clock.x + clock.textLeft + weatherButton.x + weatherButton.width) / 2

            readonly property bool popupsOpen: calendarWindow.open
                || musicWindow.open
                || networkWindow.open
                || bluetoothWindow.open
                || notificationCenterOpen
                || audioOpen
                || weatherOpen
            readonly property bool showBar: !fullscreen || fullscreenRevealed || popupsOpen
            readonly property int edgeTrigger: 6
            readonly property int shownWidth: vertical
                ? Constants.barVerticalWidth
                : Math.min(screen.width * Constants.barWidthRatio, Constants.barMaxWidth)
            readonly property int shownHeight: vertical
                ? screen.height * Constants.barHeightRatio
                : Constants.barHeight
            // 0 = shown, 1 = slid off-edge. Never resize the layer surface:
            // Hyprland was leaving it stuck at 6px (xywh 2580x6, alpha 0).
            property real hideProgress: 0

            screen: modelData
            visible: root.isUsableScreen(modelData)

            Component.onCompleted: {
                if (visible)
                    root.registerWindow(bar)

            }

            Component.onDestruction: root.unregisterWindow(bar)

            onVisibleChanged: {
                if (visible)
                    root.registerWindow(bar)
                else
                    root.unregisterWindow(bar)
            }

            onScreenChanged: {
                if (visible && root.isUsableScreen(screen))
                    root.registerWindow(bar)
            }

            function closePopups() {
                calendarWindow.open = false
                musicWindow.open = false
                networkWindow.open = false
                bluetoothWindow.open = false
                root.audioCloseRequested()
                root.weatherCloseRequested()
            }

            function toggleAudio() {
                if (bar.audioOpen) {
                    root.audioCloseRequested()
                    return
                }
                closePopups()
                // Announce before opening: popupOpened closes the other
                // features, and the audio panel is what is opening here.
                root.popupOpened()
                root.audioToggleRequested()
            }

            function toggleCalendar() { toggleLayerPopup(calendarWindow) }

            function toggleWeather() {
                if (bar.weatherOpen) {
                    root.weatherCloseRequested()
                    return
                }
                closePopups()
                root.popupOpened()
                root.weatherToggleRequested()
            }

            function toggleLayerPopup(panel) {
                const shouldOpen = !panel.open
                closePopups()
                if (shouldOpen) {
                    panel.open = true
                    root.popupOpened()
                }
            }

            function toggleNetwork() { toggleLayerPopup(networkWindow) }
            function toggleBluetooth() { toggleLayerPopup(bluetoothWindow) }
            function toggleMusic() { toggleLayerPopup(musicWindow) }

            anchors {
                top: !bar.vertical
                left: bar.vertical
            }

            implicitWidth: shownWidth
            implicitHeight: shownHeight

            exclusiveZone: fullscreen
                ? 0
                : (bar.vertical ? Constants.barVerticalWidth : Constants.barHeight)

            margins {
                top: bar.vertical ? 0 : Constants.barTopMargin
                left: bar.vertical ? Constants.barTopMargin : 0
            }

            color: "transparent"
            surfaceFormat.opaque: false
            aboveWindows: true

            WlrLayershell.namespace: "quickshell-bar"
            // Top layer sits under Hyprland fullscreen (mode 2). Overlay stays
            // hittable so the edge strip can reveal the bar.
            WlrLayershell.layer: WlrLayer.Overlay

            // Hidden: only the edge strip takes input so the fullscreen app
            // stays clickable. Shown: full bar. Do not shrink the surface.
            mask: Region {
                width: bar.vertical
                    ? (bar.showBar ? bar.shownWidth : bar.edgeTrigger)
                    : bar.width
                height: bar.vertical
                    ? bar.height
                    : (bar.showBar ? bar.shownHeight : bar.edgeTrigger)
            }

            onFullscreenChanged: {
                if (!fullscreen)
                    fullscreenRevealed = false
            }

            Process {
                id: fsProc

                command: ["hyprctl", "-j", "activeworkspace"]
                stdout: StdioCollector {
                    waitForEnd: true
                    onStreamFinished: {
                        try {
                            const ws = JSON.parse(text || "{}")
                            const hidden = ws.hasfullscreen === true
                            if (bar.fullscreen !== hidden)
                                bar.fullscreen = hidden
                            if (!hidden)
                                bar.fullscreenRevealed = false
                        } catch (e) {
                        }
                    }
                }
            }

            Timer {
                interval: 150
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    if (!fsProc.running)
                        fsProc.running = true
                }
            }

            onShowBarChanged: {
                hideAnim.stop()
                hideAnim.from = hideProgress
                hideAnim.to = showBar ? 0 : 1
                hideAnim.start()
            }

            NumberAnimation {
                id: hideAnim

                target: bar
                property: "hideProgress"
                duration: 260
                easing.type: Easing.OutCubic
            }

            onPopupsOpenChanged: {
                if (!popupsOpen && fullscreen && !barHover.hovered)
                    hideBarTimer.restart()
            }

            // Stays in place when the chrome slides off. HoverHandler on the
            // translated bar never sees the cursor.
            Item {
                id: edgeHit

                anchors.top: parent.top
                anchors.left: parent.left
                z: 100
                width: bar.vertical ? bar.edgeTrigger : parent.width
                height: bar.vertical ? parent.height : bar.edgeTrigger
                visible: bar.fullscreen

                HoverHandler {
                    id: edgeHover

                    onHoveredChanged: {
                        if (hovered) {
                            hideBarTimer.stop()
                            bar.fullscreenRevealed = true
                        } else if (!bar.popupsOpen && !barHover.hovered) {
                            hideBarTimer.restart()
                        }
                    }
                }
            }

            HoverHandler {
                id: barHover

                enabled: bar.fullscreen && bar.showBar
                onHoveredChanged: {
                    if (hovered) {
                        hideBarTimer.stop()
                        bar.fullscreenRevealed = true
                    } else if (!bar.popupsOpen && !edgeHover.hovered) {
                        hideBarTimer.restart()
                    }
                }
            }

            Timer {
                id: hideBarTimer

                interval: 500
                repeat: false
                onTriggered: {
                    if (bar.fullscreen && !barHover.hovered && !edgeHover.hovered && !bar.popupsOpen)
                        bar.fullscreenRevealed = false
                }
            }

            Rectangle {
                id: barBackground

                anchors.fill: parent
                clip: true

                radius: Constants.panelRadius
                color: Colors.surfaceContainerLow

                transform: Translate {
                    x: bar.vertical ? -bar.shownWidth * bar.hideProgress : 0
                    y: bar.vertical ? 0 : -bar.shownHeight * bar.hideProgress
                }

                ShapePath {
          fillColor: Colors.surfaceContainerLow
          strokeColor: "transparent"

          startX: 0
          startY: 0

          PathLine { x: barBackground.width; y: 0 }
          PathLine { x: barBackground.width - slopeWidth; y: barBackground.height }
          PathLine { x: slopeWidth; y: barBackground.height }
          PathLine { x: 0; y: 0 }
      }

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: bar.vertical ? Constants.paddingSm : 0
                    anchors.leftMargin: Constants.paddingSm
                    anchors.rightMargin: Constants.paddingSm

                    columns: bar.vertical ? 1 : 5
                    columnSpacing: Constants.spacingMd
                    rowSpacing: Constants.spacingMd

                    Workspaces {
                        Layout.column: 0
                        Layout.row: 0
                        Layout.fillWidth: bar.vertical
                        Layout.alignment: Qt.AlignHCenter
                        vertical: bar.vertical
                    }

                    Item {
                        Layout.fillWidth: !bar.vertical
                        Layout.fillHeight: bar.vertical
                        Layout.column: bar.vertical ? 0 : 1
                        Layout.row: bar.vertical ? 1 : 0
                    }

                    Item {
                        Layout.column: bar.vertical ? 0 : 2
                        Layout.row: bar.vertical ? 2 : 0
                    }

                    Item {
                        Layout.fillWidth: !bar.vertical
                        Layout.fillHeight: bar.vertical
                        Layout.column: bar.vertical ? 0 : 3
                        Layout.row: bar.vertical ? 3 : 0
                    }

                    GridLayout {
                        Layout.column: bar.vertical ? 0 : 4
                        Layout.row: bar.vertical ? 4 : 0
                        Layout.alignment: Qt.AlignCenter
                        columns: bar.vertical ? 1 : 6
                        columnSpacing: Constants.spacingXs
                        rowSpacing: Constants.spacingXs

                        AudioButton {
                            active: bar.audioOpen
                            glyph: audioIcon
                            muted: audioMuted

                            onClicked: bar.toggleAudio()
                        }

                        RecordingButton {
                            recording: bar.recording
                            onClicked: root.recordingStopClicked()
                        }

                        MusicButton {
                            id: music

                            onClicked: bar.toggleMusic()
                        }

                        BluetoothButton {
                            id: bluetooth
                            active: bluetoothWindow.open

                            onClicked: bar.toggleBluetooth()
                        }

                        NetworkButton {
                            id: network
                            active: networkWindow.open

                            onClicked: bar.toggleNetwork()
                        }

                        NotificationButton {
                            count: bar.notificationCount
                            active: bar.notificationCenterOpen
                            doNotDisturb: bar.doNotDisturb

                            onClicked: {
                                bar.closePopups()
                                root.notificationsClicked()
                            }
                        }
                    }
                }

                Clock {
                    id: clock

                    // Weather rides to the right of the clock rather than in
                    // the right cluster: it is a read-out that belongs next to
                    // the other ambient one, not another chrome button.
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    vertical: bar.vertical

                    onClicked: bar.toggleLayerPopup(calendarWindow)
                }

                WeatherButton {
                    id: weatherButton

                    active: bar.weatherOpen
                    glyph: weatherGlyph

                    // Horizontal bar: to the right of the clock. Vertical bar:
                    // under it, which is the same edge in that orientation.
                    //
                    // The clock item is wider than its text (it holds a 160px
                    // minimum for the marquee), so anchoring to the item's edge
                    // left a gap several times the margin. Pull the button back
                    // by that slack so the gap is the margin and nothing else —
                    // except while the marquee is showing, which fills the item.
                    anchors.left: bar.vertical ? undefined : clock.right
                    anchors.top: bar.vertical ? clock.bottom : undefined
                    anchors.leftMargin: bar.vertical
                        ? 0
                        : (clock.showMusic ? Constants.spacingMd : 8 - clock.textLeft)
                    anchors.topMargin: bar.vertical ? Constants.spacingXs : 0
                    anchors.verticalCenter: bar.vertical ? undefined : clock.verticalCenter

                    onClicked: bar.toggleWeather()
                }
            }

            // The calendar is hosted the same way as the weather panel so both
            // popups land in exactly the same place. Anchoring a PopupWindow to
            // the clock item put the calendar off to one side: the anchor rect
            // and its gravity do not place a popup the way "centre on item"
            // reads, and the drift changed with the clock's width.
            LayerPopup {
                id: calendarWindow

                centerContent: true
                // Centre of the clock + weather button, not the middle of the bar.
                hostCenterOffset: bar.centerClusterCenterX - barBackground.width / 2

                CalendarPopup {
                    id: calendar

                    open: calendarWindow.open
                }
            }

            component LayerPopup: PanelWindow {
                id: layer

                property bool open: false
                // When true the popup does not own `open`: something else (a
                // feature facade) does, and the popup asks it to close instead
                // of writing to a bound property.
                property bool externallyOpen: false
                // Centre the content on the bar rather than aligning it to the
                // bar's right edge.
                property bool centerContent: false
                // Shift of the centred host, for popups that should sit on the
                // middle of the centre cluster rather than the middle of the bar.
                property real hostCenterOffset: 0
                default property alias content: host.data

                signal closeRequested()

                readonly property int contentTop: bar.vertical
                    ? Constants.spacingMd
                    : Constants.barTopMargin + Constants.barHeight + Constants.spacingMd
                readonly property int contentRight: bar.vertical
                    ? Constants.spacingMd
                    : Math.max(
                        Constants.spacingMd,
                        Math.round(((screen ? screen.width : 0) - bar.implicitWidth) / 2)
                    )
                readonly property int contentLeft: bar.vertical
                    ? Constants.barTopMargin + Constants.barVerticalWidth + Constants.spacingMd
                    : Constants.spacingMd

                screen: bar.screen
                visible: open
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                aboveWindows: true
                focusable: true
                surfaceFormat.opaque: false

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: open
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onClicked: {
                        if (layer.externallyOpen)
                            layer.closeRequested()
                        else
                            layer.open = false
                    }
                }

                Item {
                    id: keyCatcher
                    anchors.fill: parent
                    focus: layer.open
                    Keys.onEscapePressed: {
                        if (layer.externallyOpen)
                            layer.closeRequested()
                        else
                            layer.open = false
                    }

                    Connections {
                        target: layer
                        function onOpenChanged() {
                            if (layer.open)
                                Qt.callLater(() => keyCatcher.forceActiveFocus())
                        }
                    }
                }

                Item {
                    id: host
                    anchors.top: parent.top
                    anchors.horizontalCenter: layer.centerContent ? parent.horizontalCenter : undefined
                    anchors.horizontalCenterOffset: layer.centerContent ? layer.hostCenterOffset : 0
                    anchors.right: bar.vertical || layer.centerContent ? undefined : parent.right
                    anchors.left: bar.vertical ? parent.left : undefined
                    anchors.topMargin: layer.contentTop
                    anchors.rightMargin: bar.vertical || layer.centerContent ? 0 : layer.contentRight
                    anchors.leftMargin: bar.vertical ? layer.contentLeft : 0
                    width: childrenRect.width
                    height: childrenRect.height

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.AllButtons
                        z: -1
                    }
                }
            }

            LayerPopup {
                id: musicWindow

                MusicPopup {
                    open: musicWindow.open
                }
            }

            LayerPopup {
                id: networkWindow

                NetworkPopup {
                    open: networkWindow.open
                }
            }

            LayerPopup {
                id: bluetoothWindow

                BluetoothPopup {
                    open: bluetoothWindow.open
                }
            }

            // Weather centres on the clock, the same anchor the calendar popup
            // uses, so the panel cannot drift away from the button that opened
            // it. `open` is owned by the weather feature.
            LayerPopup {
                id: weatherWindow

                open: bar.weatherOpen
                externallyOpen: true
                centerContent: true

                onCloseRequested: root.weatherCloseRequested()

                // Loaded, not declared: the panel reads the weather facade from
                // its module, and the facade registers itself after this window
                // is built. Loading it only once the facade exists keeps the
                // panel's bindings from evaluating against a null facade.
                Loader {
                    active: !!WeatherFeature.WeatherRuntime.facade
                    visible: weatherWindow.open

                    sourceComponent: Component {
                        WeatherFeature.WeatherPanel {
                            open: weatherWindow.open
                        }
                    }
                }
            }
        }
    }
}
