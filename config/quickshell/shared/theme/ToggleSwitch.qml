import QtQuick
import qs.shared.theme

// Omarchy-style bare on/off switch (track + sliding knob, no label).
// Caller owns state: bind `checked`, flip it from `toggled()`.
Item {
    id: root

    property bool checked: false
    property bool busy: false
    property bool interactive: true
    property color foreground: Colors.surfaceForeground
    property color accent: Colors.primary

    signal toggled()

    // Omarchy proportions: ~22×42 track, ~16px knob.
    property int trackHeight: Math.max(22, Math.round(Constants.buttonSize * 0.55))
    property int trackWidth: Math.round(trackHeight * 1.9)
    property int knobSize: Math.max(6, Math.round(trackHeight * 0.72))
    property int knobInset: Math.max(1, Math.round((trackHeight - knobSize) / 2))

    readonly property alias containsMouse: mouse.containsMouse

    implicitWidth: trackWidth
    implicitHeight: trackHeight

    Rectangle {
        id: track

        anchors.fill: parent
        radius: Constants.panelRadius
        // Checked = solid accent (readable on dark panels); off = elevated surface.
        color: root.checked
            ? root.accent
            : Colors.surfaceContainerHighest
        border.width: root.checked ? 0 : 1
        border.color: Colors.outlineVariant

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Rectangle {
            width: root.knobSize
            height: root.knobSize
            radius: Constants.panelRadius
            x: root.checked
                ? track.width - width - root.knobInset
                : root.knobInset
            anchors.verticalCenter: parent.verticalCenter
            color: root.checked
                ? Colors.primaryForeground
                : Colors.surfaceVariantForeground

            Behavior on x {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (!root.busy)
                root.toggled()
        }
    }
}
