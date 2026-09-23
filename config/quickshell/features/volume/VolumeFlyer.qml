pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.shared.theme

PanelWindow {
    id: root

    property var output: null
    property bool open: false
    property real volume: 0
    property bool muted: false

    signal hold()
    signal release()
    signal toggleMute()
    signal nudge(real delta)

    readonly property real level: muted ? 0 : Math.max(0, Math.min(1, volume))
    readonly property real overflowT: muted
        ? 0
        : Math.max(0, Math.min(1, (volume - 1) / 0.5))
    readonly property int percent: muted ? 0 : Math.round(volume * 100)
    readonly property string percentLabel: muted ? "muted" : (percent + "%")
    readonly property int flyerWidth: 252
    readonly property int flyerHeight: 44
    readonly property int bottomGap: Constants.visualizerHeight + Constants.spacingXl
    readonly property int sideGap: output
        ? Math.max(0, Math.round((output.width - flyerWidth) / 2))
        : 0
    readonly property color toneStart: mixColor(
        Colors.primaryContainer,
        Colors.error,
        overflowT * 0.45
    )
    readonly property color toneEnd: mixColor(Colors.primary, Colors.error, overflowT)
    readonly property color fillColor: muted ? Colors.error : toneEnd

    function mixColor(a, b, t) {
        const u = Math.max(0, Math.min(1, t))
        return Qt.rgba(
            a.r * (1 - u) + b.r * u,
            a.g * (1 - u) + b.g * u,
            a.b * (1 - u) + b.b * u,
            a.a * (1 - u) + b.a * u
        )
    }

    property bool visibleSurface: false

    screen: output
    visible: (open || visibleSurface) && output
    color: "transparent"
    implicitWidth: flyerWidth
    implicitHeight: flyerHeight
    exclusiveZone: 0
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: false
    surfaceFormat.opaque: false

    anchors {
        left: true
        right: true
        bottom: true
    }

    margins {
        left: sideGap
        right: sideGap
        bottom: bottomGap
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-volume-osd"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    onOpenChanged: {
        if (open) {
            visibleSurface = true
            hideAnim.stop()
            showAnim.restart()
        } else if (visibleSurface) {
            showAnim.stop()
            hideAnim.restart()
        }
    }

    SequentialAnimation {
        id: showAnim
        ParallelAnimation {
            NumberAnimation {
                target: flyer
                property: "opacity"
                to: 1
                duration: Constants.popupEnterMs
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: flyer
                property: "scale"
                to: 1
                duration: Constants.popupEnterMs
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: rise
                property: "y"
                to: 0
                duration: Constants.popupEnterMs
                easing.type: Easing.OutCubic
            }
        }
    }

    SequentialAnimation {
        id: hideAnim
        ParallelAnimation {
            NumberAnimation {
                target: flyer
                property: "opacity"
                to: 0
                duration: Constants.popupExitMs
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: flyer
                property: "scale"
                to: Constants.popupFromScale
                duration: Constants.popupExitMs
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: rise
                property: "y"
                to: 8
                duration: Constants.popupExitMs
                easing.type: Easing.InCubic
            }
        }
        ScriptAction {
            script: root.visibleSurface = false
        }
    }

    Rectangle {
        id: flyer

        anchors.fill: parent
        color: Colors.surfaceContainerLow
        opacity: 0
        scale: Constants.popupFromScale
        transformOrigin: Item.Bottom

        transform: Translate {
            id: rise
            y: 8
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            onEntered: root.hold()
            onExited: root.release()
            onClicked: root.toggleMute()
            onWheel: event => {
                root.nudge(event.angleDelta.y > 0 ? 0.05 : -0.05)
                event.accepted = true
            }
        }

        RowLayout {
            anchors {
                fill: parent
                leftMargin: Constants.paddingLg
                rightMargin: Constants.paddingLg
            }
            spacing: Constants.spacingSm

            Item {
                Layout.preferredWidth: Constants.iconSizeLg
                Layout.preferredHeight: Constants.iconSizeLg

                ThemeIcon {
                    anchors.fill: parent
                    name: "volume"
                    iconSize: Constants.iconSizeLg
                    iconColor: root.fillColor
                    opacity: root.muted ? 0.55 : 1
                }

                Rectangle {
                    visible: root.muted
                    anchors.centerIn: parent
                    width: parent.width + 2
                    height: 1.5
                    rotation: -32
                    color: Colors.error
                    antialiasing: true
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 10

                Rectangle {
                    id: track

                    anchors.fill: parent
                    color: Tokens.whiteHairline

                    Item {
                        width: parent.width * root.level
                        height: parent.height
                        clip: true

                        Behavior on width {
                            NumberAnimation {
                                duration: Constants.animationFast
                                easing.type: Easing.OutCubic
                            }
                        }

                        Rectangle {
                            width: track.width
                            height: parent.height
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop {
                                    position: 0
                                    color: root.muted ? Colors.error : root.toneStart
                                }
                                GradientStop {
                                    position: 1
                                    color: root.fillColor
                                }
                            }
                        }
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: root.percentLabel
                color: root.fillColor
                font.family: Constants.fontFamily
                font.pixelSize: Constants.fontSizeXs
                font.weight: Font.Medium
            }
        }
    }
}
