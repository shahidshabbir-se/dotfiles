import QtQuick
import QtQuick.Effects

Item {
    id: root

    required property url artworkSource
    required property bool entranceReady

    readonly property color backgroundColor: "#09080e"

    z: -1

    Rectangle {
        anchors.fill: parent
        color: root.backgroundColor
    }

    Image {
        id: backdropImage

        x: -root.width * 0.12
        y: -root.height * 0.08
        width: root.width * 1.24
        height: root.height * 1.20
        source: root.artworkSource
        sourceSize: Qt.size(
            Math.round(root.width * 1.5),
            Math.round(root.height * 1.5)
        )
        fillMode: Image.PreserveAspectCrop
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignTop
        smooth: true
        mipmap: true
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: backdropImage
        blurEnabled: true
        blur: 0.82
        blurMax: 48
        saturation: -0.18
        brightness: -0.11
        contrast: -0.05
        autoPaddingEnabled: false
        opacity: root.entranceReady ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 700
                easing.type: Easing.OutCubic
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#1809080e"
        opacity: root.entranceReady ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 520
                easing.type: Easing.OutCubic
            }
        }
    }

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            orientation: Gradient.Vertical

            GradientStop { position: 0.00; color: "#0809080e" }
            GradientStop { position: 0.24; color: "#1009080e" }
            GradientStop { position: 0.34; color: "#2009080e" }
            GradientStop { position: 0.42; color: "#4209080e" }
            GradientStop { position: 0.50; color: "#7209080e" }
            GradientStop { position: 0.58; color: "#b209080e" }
            GradientStop { position: 0.65; color: "#e809080e" }
            GradientStop { position: 0.71; color: root.backgroundColor }
            GradientStop { position: 1.00; color: root.backgroundColor }
        }
    }

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            orientation: Gradient.Vertical

            GradientStop { position: 0.00; color: "#26000000" }
            GradientStop { position: 0.18; color: "#10000000" }
            GradientStop { position: 0.40; color: "#00000000" }
            GradientStop { position: 1.00; color: "#00000000" }
        }
    }
}
