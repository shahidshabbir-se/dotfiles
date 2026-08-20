pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.shared.theme

PanelWindow {
    id: window

    property bool open: false
    property bool recording: false
    signal closeRequested()
    signal actionStarted()

    property int selectedIndex: 0

    readonly property string featureDir: Quickshell.shellPath("features/screenshot")
    readonly property var actions: [
        { id: "screen",       glyph: "󰹑", label: "Screen" },
        { id: "area",         glyph: "󰩬", label: "Area" },
        { id: "window",       glyph: "󰖲", label: "Window" },
        { id: "screen-delay", glyph: "󱎫", label: "Delay" },
        { id: "area-delay",   glyph: "󰄉", label: "Area+" },
        { id: "record",       glyph: "󰕧", label: "Record" }
    ]

    implicitWidth: Screen.width
    implicitHeight: Screen.height
    color: "transparent"
    focusable: true
    visible: open

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-screenshot"

    // Detached so slurp/grim aren't killed when the overlay tears down.
    function runAction(id) {
        window.closeRequested()
        // Defer past overlay unmap + exclusive-focus release.
        launchTimer.actionId = id
        launchTimer.restart()
    }

    function moveSelection(delta) {
        const n = actions.length
        selectedIndex = (selectedIndex + delta + n) % n
    }

    function activateSelected() {
        runAction(actions[selectedIndex].id)
    }

    onOpenChanged: {
        if (open) {
            selectedIndex = 0
            entrance.play()
            Qt.callLater(() => keySink.forceActiveFocus())
        } else {
            entrance.reset()
        }
    }

    Timer {
        id: launchTimer
        property string actionId: ""
        interval: 180
        repeat: false
        onTriggered: {
            Quickshell.execDetached([
                "bash",
                window.featureDir + "/scripts/capture.sh",
                actionId
            ])
            window.actionStarted()
            if (actionId === "record")
                refreshSoon.restart()
        }
    }

    Timer {
        id: refreshSoon
        interval: 700
        repeat: false
        onTriggered: window.actionStarted()
    }

    QtObject {
        id: entrance
        property real revealProgress: 0
        function play() {
            reset()
            Qt.callLater(() => {
                if (window.open)
                    revealProgress = 1
            })
        }
        function reset() {
            revealProgress = 0
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Tokens.withAlpha(Colors.shadow, 0.55 * entrance.revealProgress)

        MouseArea {
            anchors.fill: parent
            onClicked: window.closeRequested()
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 600
        height: header.implicitHeight + grid.implicitHeight + 40
        radius: 0
        color: Colors.background
        border.width: 1
        border.color: Colors.primary
        opacity: entrance.revealProgress
        scale: Constants.popupFromScale + entrance.revealProgress * (1 - Constants.popupFromScale)

        Behavior on opacity {
            NumberAnimation { duration: Constants.popupEnterMs }
        }
        Behavior on scale {
            NumberAnimation { duration: Constants.popupEnterMs }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            RowLayout {
                id: header
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 40
                    color: Colors.tertiary
                    radius: 0

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: Colors.background
                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                        font.pixelSize: 14
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: window.recording ? Colors.error : Colors.primary
                    radius: 0

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: window.recording ? "Recording…" : "Screenshot"
                        color: window.recording
                            ? Colors.errorContainerForeground
                            : Colors.background
                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                        font.pixelSize: 13
                    }
                }
            }

            RowLayout {
                id: grid
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: window.actions

                    Rectangle {
                        id: cell
                        required property var modelData
                        required property int index

                        readonly property bool activeRec:
                            modelData.id === "record" && window.recording

                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        radius: 0
                        border.width: 1
                        border.color: activeRec ? Colors.error : Colors.primary
                        color: {
                            if (window.selectedIndex === index)
                                return activeRec ? Colors.error : Colors.primary
                            if (activeRec)
                                return Colors.errorContainer
                            if (hover.hovered)
                                return Colors.surfaceContainerHigh
                            return Colors.background
                        }

                        Text {
                            anchors.centerIn: parent
                            text: cell.modelData.glyph
                            color: {
                                if (window.selectedIndex === index)
                                    return cell.activeRec
                                        ? Colors.errorContainerForeground
                                        : Colors.background
                                if (cell.activeRec)
                                    return Colors.errorContainerForeground
                                return Colors.backgroundForeground
                            }
                            font.family: "JetBrainsMono Nerd Font"
                            font.bold: true
                            font.pixelSize: 22
                        }

                        HoverHandler {
                            id: hover
                            onHoveredChanged: {
                                if (hovered)
                                    window.selectedIndex = cell.index
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: window.runAction(cell.modelData.id)
                        }
                    }
                }
            }
        }

        FocusScope {
            id: keySink
            anchors.fill: parent
            focus: window.open

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    window.closeRequested()
                    event.accepted = true
                } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
                    window.moveSelection(-1)
                    event.accepted = true
                } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
                    window.moveSelection(1)
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    window.activateSelected()
                    event.accepted = true
                } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_6) {
                    window.selectedIndex = event.key - Qt.Key_1
                    window.activateSelected()
                    event.accepted = true
                }
            }
        }
    }
}
