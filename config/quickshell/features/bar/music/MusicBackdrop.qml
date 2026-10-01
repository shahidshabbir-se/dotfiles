import QtQuick
import QtQuick.Effects
import qs.shared.theme

Item {
    id: root

    required property url artworkSource
    required property bool entranceReady
    // The artwork wash is only for a panel that has something to show. With
    // nothing playing the popup falls back to the flat surface color, which
    // reads cleaner than a blurred placeholder disc. Paused counts as loaded:
    // the artwork is still on screen, and pulling the wash out on pause would
    // fight the pause itself.
    required property bool active

    readonly property color backgroundColor: Colors.surfaceContainerLow

    // Driven by `active` alone, never by `entranceReady`. The popup window
    // already fades and scales itself on `entrance.revealProgress`, and
    // `entranceReady` re-arms on every open, so binding to it here made the
    // wash sit at whatever the fade had not reached yet and read as flat.
    // Not readonly: Behavior needs to write it.
    property real artOpacity: active ? 1 : 0

    Behavior on artOpacity {
        NumberAnimation {
            duration: 420
            easing.type: Easing.OutCubic
        }
    }

    // No `z` here. The backdrop is a child of the popup's opaque shell
    // Rectangle, and a negative z drops it behind that fill — which is how it
    // ended up invisible and reading as a flat panel. It is already declared
    // ahead of the content, so it paints first either way.

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
        opacity: root.artOpacity
    }

    Rectangle {
        anchors.fill: parent
        color: Tokens.withAlpha(root.backgroundColor, 0.1)
        opacity: root.artOpacity
    }

    // Washes the artwork out toward the bottom of the panel, so the text and
    // controls at the bottom always sit on a flat, legible surface.
    Rectangle {
        anchors.fill: parent
        opacity: root.artOpacity

        gradient: Gradient {
            orientation: Gradient.Vertical

            GradientStop { position: 0.00; color: Tokens.withAlpha(root.backgroundColor, 0.03) }
            GradientStop { position: 0.24; color: Tokens.withAlpha(root.backgroundColor, 0.06) }
            GradientStop { position: 0.34; color: Tokens.withAlpha(root.backgroundColor, 0.12) }
            GradientStop { position: 0.42; color: Tokens.withAlpha(root.backgroundColor, 0.26) }
            GradientStop { position: 0.50; color: Tokens.withAlpha(root.backgroundColor, 0.45) }
            GradientStop { position: 0.58; color: Tokens.withAlpha(root.backgroundColor, 0.70) }
            GradientStop { position: 0.65; color: Tokens.withAlpha(root.backgroundColor, 0.91) }
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
