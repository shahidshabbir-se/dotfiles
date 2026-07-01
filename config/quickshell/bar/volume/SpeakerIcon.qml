import QtQuick
import Qt5Compat.GraphicalEffects
import qs.configuration

Item {
    id: root

    property bool muted: false
    property real volume: 0
    property color tintColor: "transparent"

    readonly property bool useCustomTint: tintColor.a > 0
    readonly property bool showAsMuted: muted || volume <= 0

    readonly property string iconSource: showAsMuted
        ? "../assets/svg/speaker-mute.svg"
        : "../assets/svg/speaker2.svg"

    readonly property real iconOpacity: showAsMuted ? 0.45 : 0.9

    opacity: iconOpacity

    Image {
        id: icon
        anchors.fill: parent
        source: root.iconSource
        fillMode: Image.PreserveAspectFit
        visible: root.useCustomTint
    }

    Rectangle {
        id: gradientSource
        anchors.fill: parent
        visible: false
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: Colors.matugen.primary }
            GradientStop { position: 1; color: Colors.matugen.secondary }
        }
    }

    OpacityMask {
        anchors.fill: parent
        source: gradientSource
        maskSource: icon
        visible: !useCustomTint
    }

    ColorOverlay {
        anchors.fill: icon
        source: icon
        color: tintColor
        visible: useCustomTint
    }
}
