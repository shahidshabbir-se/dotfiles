pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.shared.theme

// Full-screen overlay that hosts the audio panel, so the panel can sit under the
// bar and take the keyboard while it is open. Same shape as the bar's LayerPopup,
// owned by the feature instead so `audio.open` is the single source of truth.
PanelWindow {
    id: window

    screen: audio.screen

    required property var audio

    property bool open: false
    // `open` mirrors the facade and is never assigned here: writing to it would
    // break the binding and leave the facade thinking the panel is still up.

    readonly property int topOffset: audio.barVertical
        ? Constants.spacingMd
        : Constants.barTopMargin + Constants.barHeight + Constants.spacingMd
    readonly property int rightOffset: audio.barVertical
        ? Constants.spacingMd
        : Math.max(
            Constants.spacingMd,
            Math.round(
                (((audio.screen ? audio.screen.width : 0) - audio.barWidth) / 2)
            )
        )

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: open
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: true
    surfaceFormat.opaque: false

    WlrLayershell.namespace: "quickshell-audio"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    // Only hit-test while open; closed, the panel must not shadow the desktop.
    mask: Region {
        width: window.open && window.screen ? window.screen.width : 0
        height: window.open && window.screen ? window.screen.height : 0
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: window.audio.close()
    }

    AudioPanel {
        id: panel

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: window.topOffset
        anchors.rightMargin: window.rightOffset
        audio: window.audio

        // Scaling out of the corner the panel is anchored to, not its middle.
        transformOrigin: Item.TopRight
        opacity: window.open ? 1 : 0
        scale: 1

        Behavior on opacity {
            NumberAnimation {
                duration: window.open ? Constants.popupEnterMs : Constants.popupExitMs
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: window.open ? Constants.popupEnterMs : Constants.popupExitMs
                easing.type: Easing.OutCubic
            }
        }
    }

    // Keyboard cursor lives here so it works no matter which row has the mouse.
    Item {
        id: keys

        anchors.fill: parent
        focus: window.open

        Keys.onPressed: function(event) {
            const key = event.key
            const audio = window.audio

            if (key === Qt.Key_Escape) {
                window.audio.close()
                return
            }

            switch (key) {
            case Qt.Key_Down:
            case Qt.Key_J:
                if (!audio.cursorActive)
                    audio.revealCursor()
                else
                    audio.moveCursor(1)
                return
            case Qt.Key_Up:
            case Qt.Key_K:
                if (!audio.cursorActive)
                    audio.revealCursor()
                else
                    audio.moveCursor(-1)
                return
            case Qt.Key_Right:
            case Qt.Key_L:
                if (!audio.cursorActive)
                    audio.revealCursor()
                else
                    audio.adjustVolume(0.05)
                return
            case Qt.Key_Left:
            case Qt.Key_H:
                if (!audio.cursorActive)
                    audio.revealCursor()
                else
                    audio.adjustVolume(-0.05)
                return
            case Qt.Key_Return:
            case Qt.Key_Enter:
            case Qt.Key_Space:
                audio.activateCursor()
                return
            case Qt.Key_M:
                if (audio.cursorActive)
                    audio.toggleMuteFocused()
                return
            case Qt.Key_Tab:
                audio.moveSection(event.modifiers & Qt.ShiftModifier ? -1 : 1)
                return
            }
        }
    }

    onOpenChanged: {
        if (open)
            Qt.callLater(() => keys.forceActiveFocus())
    }
}

