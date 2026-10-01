pragma ComponentBehavior: Bound

import QtQuick
import qs.shared.theme

// Flat volume slider: 2px track, accent fill, no knob chrome.
// Modeled directly on the music player's VolumeControl: continuous 1:1 tracking
// while dragging, and 140ms OutCubic animation for external volume changes.
Item {
    id: root

    property real value: 0
    property real minimum: 0
    property real maximum: 1
    property real step: 0.05
    property bool dragging: false
    property bool interactive: true
    // A muted channel keeps its level visible but reads as inactive.
    property bool dimmed: false
    property color accentColor: Colors.primary

    signal moved(real value)
    signal toggleMute()

    readonly property real span: Math.max(0.0001, maximum - minimum)

    // Tracks live drag position so the slider follows the mouse continuously
    // without fighting asynchronous PipeWire readbacks.
    property real pendingValue: value

    onValueChanged: {
        if (!root.dragging)
            pendingValue = value
    }

    readonly property real shown: Math.max(0, Math.min(1, (pendingValue - minimum) / span))
    readonly property real shownValue: pendingValue
    readonly property real dragValue: pendingValue

    implicitHeight: 18
    implicitWidth: 160

    function valueAt(x) {
        const fraction = Math.max(0, Math.min(1, x / Math.max(1, width)))
        return minimum + fraction * span
    }

    property real lastRequested: NaN

    function updateFromMouse(x) {
        if (!root.interactive)
            return
        const next = root.valueAt(x)
        root.pendingValue = next
        if (!isNaN(root.lastRequested) && Math.abs(next - root.lastRequested) < 0.001)
            return
        root.lastRequested = next
        root.moved(next)
    }

    // Same slider as the music player's volume: 2px track, accent fill, and a
    // round thumb that grows while it is being dragged. The fill animates when
    // the level comes from the system and not while it is being dragged, or the
    // animation would lag the pointer.
    Rectangle {
        id: track

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 2
        radius: height / 2
        color: "#35ffffff"
        opacity: root.dimmed ? 0.45 : 1

        Rectangle {
            width: track.width * root.shown
            height: parent.height
            radius: parent.radius
            color: root.accentColor

            Behavior on width {
                enabled: !root.dragging

                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    Rectangle {
        x: track.x + track.width * root.shown - width / 2
        anchors.verticalCenter: track.verticalCenter
        width: 12
        height: 12
        radius: width / 2
        color: root.accentColor
        opacity: root.dimmed ? 0.45 : 1
        scale: root.dragging ? 1.18 : 1

        Behavior on x {
            enabled: !root.dragging

            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                root.toggleMute()
                return
            }
            root.dragging = true
            root.lastRequested = NaN
            root.updateFromMouse(mouse.x)
        }
        onPositionChanged: function(mouse) {
            if (root.dragging)
                root.updateFromMouse(mouse.x)
        }
        onReleased: function(mouse) {
            if (mouse.button === Qt.RightButton)
                return
            if (root.dragging) {
                root.updateFromMouse(mouse.x)
                root.dragging = false
                root.lastRequested = NaN
            }
        }
        onCanceled: function() {
            root.dragging = false
            root.lastRequested = NaN
        }
        onWheel: function(wheel) {
            if (!root.interactive)
                return
            const wheelStep = root.step > 0 ? root.step : 0.05
            const delta = (wheel.angleDelta.y / 120) * wheelStep
            if (delta === 0)
                return
            wheel.accepted = true
            const next = Math.max(root.minimum, Math.min(root.maximum, root.pendingValue + delta))
            root.pendingValue = next
            root.moved(next)
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: Constants.animationFast }
    }
}
