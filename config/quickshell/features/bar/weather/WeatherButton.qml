import QtQuick
import qs.shared.theme

// Bar button for the weather panel. Dumb on purpose: the weather feature owns
// the state, the button only draws what it is handed.
Item {
    id: root

    property bool active: false
    // Weather condition glyph; empty until the first successful fetch. The
    // temperature is deliberately not shown here — the glyph alone is the
    // ambient indicator, and the panel is one click away for the numbers.
    property string glyph: ""

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
        opacity: root.glyph.length > 0 ? 1 : 0.55

        Text {
            anchors.centerIn: parent
            visible: root.glyph.length > 0
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

        Behavior on scale {
            NumberAnimation {
                duration: Constants.animationFast
                easing.type: Easing.OutCubic
            }
        }
    }
}
