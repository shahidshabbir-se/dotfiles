import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
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
            rect.x: bar.vertical ? clock.width + Constants.spacingLg : 0
            rect.y: bar.vertical ? 0 : clock.height + Constants.spacingXl + Constants.spacingXs
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

    // Layer-shell panels — keyboard/IPC friendly (no xdg grab parent required).
    PanelWindow {
        id: musicWindow

        property bool open: false

        visible: open
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        focusable: true
        surfaceFormat.opaque: false

        anchors {
            top: !bar.vertical
            right: !bar.vertical
            left: bar.vertical
        }

        margins {
            top: bar.vertical
                ? 0
                : Constants.barTopMargin + Constants.barHeight + Constants.spacingLg
            right: bar.vertical
                ? 0
                : Math.max(
                    Constants.spacingLg,
                    Math.round((screen.width - bar.implicitWidth) / 2)
                )
            left: bar.vertical
                ? Constants.barTopMargin + Constants.barVerticalWidth + Constants.spacingLg
                : 0
        }

        implicitWidth: musicPopup.width
        implicitHeight: musicPopup.implicitHeight

        MusicPopup {
            id: musicPopup
            open: musicWindow.open
        }
    }

    PanelWindow {
        id: networkWindow

        property bool open: false

        visible: open
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        focusable: true
        surfaceFormat.opaque: false

        anchors {
            top: !bar.vertical
            right: !bar.vertical
            left: bar.vertical
        }

        margins {
            top: bar.vertical
                ? 0
                : Constants.barTopMargin + Constants.barHeight + Constants.spacingLg
            right: bar.vertical
                ? 0
                : Math.max(
                    Constants.spacingLg,
                    Math.round((screen.width - bar.implicitWidth) / 2)
                )
            left: bar.vertical
                ? Constants.barTopMargin + Constants.barVerticalWidth + Constants.spacingLg
                : 0
        }

        implicitWidth: networkPopup.width
        implicitHeight: networkPopup.implicitHeight

        NetworkPopup {
            id: networkPopup
            open: networkWindow.open
        }
    }
}
