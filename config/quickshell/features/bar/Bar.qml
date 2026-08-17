import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.shared.theme

PanelWindow {
    id: bar

    property int orientation: Qt.Horizontal
    property int notificationCount: 0
    property bool notificationCenterOpen: false
    property bool doNotDisturb: false
    readonly property bool vertical: orientation === Qt.Vertical

    signal notificationsClicked()
    signal popupOpened()

    // After sleep/DPMS, Qt can leave us on a placeholder output while Hyprland
    // already has a real monitor again. Notifications may still show; the bar
    // stays invisible until we rebind `screen`.
    function pickScreen() {
        const screens = Quickshell.screens
        for (let i = 0; i < screens.length; i++) {
            const s = screens[i]
            const n = (s && s.name) ? String(s.name) : ""
            if (n.length > 0 && n !== "FALLBACK" && n.indexOf("placeholder") < 0)
                return s
        }
        return screens.length > 0 ? screens[0] : null
    }

    function rebindScreen() {
        const next = pickScreen()
        if (!next)
            return
        if (bar.screen !== next)
            bar.screen = next
    }

    function closePopups() {
        calendarWindow.visible = false
        musicWindow.open = false
        networkWindow.open = false
    }

    // xdg PopupWindow (calendar) — needs pointer focus on parent sometimes.
    function toggleAnchoredPopup(popup) {
        const shouldOpen = !popup.visible
        closePopups()
        if (shouldOpen) {
            popup.visible = true
            popupOpened()
        }
    }

    // Layer-shell panels (network / music) — work from keyboard/IPC.
    function toggleLayerPopup(panel) {
        const shouldOpen = !panel.open
        closePopups()
        if (shouldOpen) {
            panel.open = true
            popupOpened()
        }
    }

    function toggleNetwork() { toggleLayerPopup(networkWindow) }
    function toggleMusic() { toggleLayerPopup(musicWindow) }

    // Hyprland: qs ipc call bar toggleNetwork / toggleMusic
    IpcHandler {
        target: "bar"

        function toggleNetwork(): void { bar.toggleNetwork() }
        function toggleMusic(): void { bar.toggleMusic() }
        function closePopups(): void { bar.closePopups() }
    }

    Component.onCompleted: rebindScreen()

    Connections {
        target: Quickshell
        function onScreensChanged() {
            bar.rebindScreen()
        }
    }

    // Catch cases where screensChanged fires before the real output is usable.
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: bar.rebindScreen()
    }

    anchors {
        top: !bar.vertical
        left: bar.vertical
    }

    implicitWidth: bar.vertical
        ? Constants.barVerticalWidth
        : Math.min(screen.width * Constants.barWidthRatio, Constants.barMaxWidth)

    implicitHeight: bar.vertical
        ? screen.height * Constants.barHeightRatio
        : Constants.barHeight

    exclusiveZone: bar.vertical
        ? Constants.barVerticalWidth
        : Constants.barHeight

    margins {
        top: bar.vertical ? 0 : Constants.barTopMargin
        left: bar.vertical ? Constants.barTopMargin : 0
    }

    color: "transparent"

    Rectangle {
        id: barBackground

        anchors.fill: parent

        radius: Constants.barRadius
        color: Colors.surfaceContainerLow

        GridLayout {
            anchors.fill: parent
            anchors.margins: bar.vertical ? Constants.paddingSm : 0
            anchors.leftMargin: bar.vertical ? Constants.paddingSm : Constants.paddingMd
            anchors.rightMargin: bar.vertical ? Constants.paddingSm : Constants.paddingMd

            columns: bar.vertical ? 1 : 5
            columnSpacing: Constants.spacingMd
            rowSpacing: Constants.spacingMd

            // Left / top
            Workspaces {
                vertical: bar.vertical
                Layout.column: 0
                Layout.row: 0
                Layout.fillWidth: bar.vertical
                Layout.alignment: Qt.AlignHCenter
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
                columns: bar.vertical ? 1 : 3
                columnSpacing: Constants.spacingXs
                rowSpacing: Constants.spacingXs

                NotificationButton {
                    count: bar.notificationCount
                    active: bar.notificationCenterOpen
                    doNotDisturb: bar.doNotDisturb

                    onClicked: {
                        bar.closePopups()
                        bar.notificationsClicked()
                    }
                }

                NetworkButton {
                    id: network
                    active: networkWindow.open

                    onClicked: bar.toggleNetwork()
                }

                MusicButton {
                    id: music

                    onClicked: bar.toggleMusic()
                }
            }

        }

        Clock {
            id: clock

            anchors.centerIn: parent
            vertical: bar.vertical

            onClicked: bar.toggleAnchoredPopup(calendarWindow)
        }
    }

    PopupWindow {
        id: calendarWindow

        anchor {
            item: clock
            // 8px under the bar (not just under clock text) — same gap as LayerPopup.
            rect.x: bar.vertical
                ? clock.width + (barBackground.width - clock.width) / 2
                    + Constants.spacingMd
                : 0
            rect.y: bar.vertical
                ? 0
                : clock.height
                    + (barBackground.height - clock.height) / 2
                    + Constants.spacingMd
            rect.width: bar.vertical ? 1 : clock.width
            rect.height: bar.vertical ? clock.height : 1
            edges: bar.vertical ? Edges.Bottom | Edges.Right : Edges.Bottom
            gravity: bar.vertical ? Edges.Top | Edges.Right : Edges.Bottom
        }

        implicitWidth: calendar.width
        implicitHeight: calendar.implicitHeight
        color: "transparent"
        grabFocus: true

        CalendarPopup {
            id: calendar
        }
    }

    // Full-screen layer panels so outside-click + Escape work (PopupWindow
    // grab fails for keyboard/IPC open; content-sized PanelWindow has no
    // outside region and no auto-dismiss).
    component LayerPopup: PanelWindow {
        id: layer

        property bool open: false
        default property alias content: host.data

        // Content sits 8px under the floating bar (spacingMd), right-aligned to bar edge.
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

        // Outside click dismisses.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: layer.open = false
        }

        // Escape dismisses (panel holds exclusive keyboard focus while open).
        Item {
            id: keyCatcher
            anchors.fill: parent
            focus: layer.open
            Keys.onEscapePressed: layer.open = false

            // Keep focus after map so Escape works without a click first.
            Connections {
                target: layer
                function onOpenChanged() {
                    if (layer.open)
                        Qt.callLater(() => keyCatcher.forceActiveFocus())
                }
            }
        }

        // Content host — clicks here must not hit the dismiss MouseArea.
        Item {
            id: host
            anchors.top: parent.top
            anchors.right: bar.vertical ? undefined : parent.right
            anchors.left: bar.vertical ? parent.left : undefined
            anchors.topMargin: layer.contentTop
            anchors.rightMargin: bar.vertical ? 0 : layer.contentRight
            anchors.leftMargin: bar.vertical ? layer.contentLeft : 0
            width: childrenRect.width
            height: childrenRect.height

            // Swallow so clicks on the card don't close the panel.
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
            id: musicPopup
            open: musicWindow.open
        }
    }

    LayerPopup {
        id: networkWindow

        NetworkPopup {
            id: networkPopup
            open: networkWindow.open
        }
    }
}
