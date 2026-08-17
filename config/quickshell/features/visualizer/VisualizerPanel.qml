import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.shared.theme

PanelWindow {
    id: root

    required property var levels
    required property bool sourceAvailable
    required property bool mediaPlaying

    readonly property real responsiveBarHeight: screen && screen.height >= 900
        ? Constants.visualizerMaxBarHeight
        : screen && screen.height >= 740 ? 42 : 32

    anchors {
        left: true
        right: true
        bottom: true
    }

    implicitHeight: Constants.visualizerHeight
    visible: sourceAvailable
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: false
    focusable: false
    surfaceFormat.opaque: false

    WlrLayershell.namespace: "quickshell-audio-visualizer"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region {
        width: root.width
        height: root.height
        intersection: Intersection.Xor
    }

    Item {
        id: spectrumFrame

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Constants.visualizerBottomMargin
        width: Math.max(
            1,
            Math.min(
                Constants.visualizerMaxWidth,
                root.width * Constants.visualizerWidthRatio,
                root.width - Constants.spacingXl * 2
            )
        )
        height: root.responsiveBarHeight
        opacity: root.mediaPlaying ? 0.86 : 0

        transform: Translate {
            y: root.mediaPlaying ? 0 : 3

            Behavior on y {
                NumberAnimation {
                    duration: Constants.animationSlow
                    easing.type: Easing.OutCubic
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.mediaPlaying
                    ? Constants.animationNormal
                    : Constants.animationSlow
                easing.type: Easing.OutCubic
            }
        }

        SpectrumBars {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: root.responsiveBarHeight
            maxBarHeight: height
            levels: root.levels
            active: root.mediaPlaying
        }
    }
}
