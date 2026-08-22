import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
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
    readonly property bool vertical: orientation === Qt.Vertical

    property var primaryWindow: null
    readonly property var screen: primaryWindow ? primaryWindow.screen : null
    readonly property int implicitWidth: primaryWindow
        ? primaryWindow.implicitWidth
        : (vertical ? Constants.barVerticalWidth : Constants.barMaxWidth)

    signal notificationsClicked()
    signal popupOpened()
    signal recordingStopClicked()

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

    IpcHandler {
        target: "bar"

        function toggleNetwork(): void { root.toggleNetwork() }
        function toggleBluetooth(): void { root.toggleBluetooth() }
        function toggleMusic(): void { root.toggleMusic() }
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
            readonly property bool vertical: orientation === Qt.Vertical

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
                calendarWindow.visible = false
                musicWindow.open = false
                networkWindow.open = false
                bluetoothWindow.open = false
            }

            function toggleAnchoredPopup(popup) {
                const shouldOpen = !popup.visible
                closePopups()
                if (shouldOpen) {
                    popup.visible = true
                    root.popupOpened()
                }
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

                radius: Constants.panelRadius
                color: Colors.surfaceContainerLow

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: bar.vertical ? Constants.paddingSm : 0
                    anchors.leftMargin: Constants.paddingSm
                    anchors.rightMargin: Constants.paddingSm

                    columns: bar.vertical ? 1 : 5
                    columnSpacing: Constants.spacingMd
                    rowSpacing: Constants.spacingMd

                    GridLayout {
                        Layout.column: 0
                        Layout.row: 0
                        Layout.fillWidth: bar.vertical
                        Layout.alignment: Qt.AlignHCenter
                        columns: bar.vertical ? 1 : 2
                        columnSpacing: Constants.spacingSm
                        rowSpacing: Constants.spacingSm

                        ThemeIcon {
                            name: "qalam"
                            iconSize: Constants.iconSizeLg * 1.5
                            Layout.preferredWidth: Constants.iconSizeLg * 1.5
                            Layout.preferredHeight: Constants.iconSizeLg * 1.5
                            Layout.alignment: Qt.AlignCenter
                        }

                        Workspaces {
                            vertical: bar.vertical
                        }
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
                        columns: bar.vertical ? 1 : 5
                        columnSpacing: Constants.spacingXs
                        rowSpacing: Constants.spacingXs

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

                    anchors.centerIn: parent
                    vertical: bar.vertical

                    onClicked: bar.toggleAnchoredPopup(calendarWindow)
                }
            }

            PopupWindow {
                id: calendarWindow

                anchor {
                    item: clock
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
                    open: calendarWindow.visible
                }
            }

            component LayerPopup: PanelWindow {
                id: layer

                property bool open: false
                default property alias content: host.data

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
                    onClicked: layer.open = false
                }

                Item {
                    id: keyCatcher
                    anchors.fill: parent
                    focus: layer.open
                    Keys.onEscapePressed: layer.open = false

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
                    anchors.right: bar.vertical ? undefined : parent.right
                    anchors.left: bar.vertical ? parent.left : undefined
                    anchors.topMargin: layer.contentTop
                    anchors.rightMargin: bar.vertical ? 0 : layer.contentRight
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
        }
    }
}
