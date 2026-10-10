import QtQuick
import qs.shared.theme

// Bar button for the audio panel. Dumb on purpose: the audio feature owns the
// state, the button only draws the glyph it is handed.
Item {
    id: root

    property bool active: false
    // Material Design speaker glyph.
    property string glyph: "󰕾"
    property bool muted: false

    signal clicked

    implicitWidth: Constants.buttonSize
    implicitHeight: Constants.buttonSize

    Rectangle {
        anchors.fill: parent
        radius: Constants.buttonRadius
        color: root.active
            ? Tokens.withAlpha(Colors.primary, 0.14)
            : (pointer.containsMouse
                ? Colors.surfaceContainerHighest
                : "transparent")
        scale: pointer.pressed ? 0.94 : 1
        opacity: root.muted ? 0.55 : 1

        Text {
            anchors.centerIn: parent
            text: root.glyph
            color: Colors.surfaceForeground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Constants.iconSizeLg + 2
        }

        MouseArea {
            id: pointer

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }

        Behavior on color {
            ColorAnimation { duration: Constants.animationFast }
        }

        Behavior on opacity {
            NumberAnimation { duration: Constants.animationFast }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Constants.animationFast
                easing.type: Easing.OutCubic
            }
        }
    }
}
