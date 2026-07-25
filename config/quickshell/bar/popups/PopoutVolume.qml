import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.configuration
import "../volume"

Scope {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property var activeScreen: Quickshell.screens.find(
        screen => screen.name === Hyprland.focusedMonitor?.name
    ) ?? Quickshell.screens[0] ?? null

    property bool shouldShowOsd: false

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio

        function onVolumeChanged() {
            root.shouldShowOsd = true
            hideTimer.restart()
        }

        function onMutedChanged() {
            root.shouldShowOsd = true
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            screen: root.activeScreen
            visible: root.shouldShowOsd && root.activeScreen !== null
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "quickshell_volume_osd"
            color: "transparent"

            anchors.bottom: true

            margins.bottom: root.activeScreen ? root.activeScreen.height / 12 : 80

            implicitWidth: 208
            implicitHeight: 44

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (sink?.audio)
                        sink.audio.muted = !root.muted
                }
                onWheel: wheel => {
                    if (!sink?.audio || root.muted)
                        return

                    const delta = wheel.angleDelta.y > 0 ? 0.1 : -0.1
                    sink.audio.volume = Math.max(0, Math.min(1.5, root.volume + delta))
                }
            }

            Rectangle {
                id: osdPanel
                anchors.centerIn: parent
                width: 200
                height: 36
                radius: 4
                color: Colors.popoutBackground
                border.width: 0
                antialiasing: true

                transform: [
                    Scale {
                        id: scaleTransform
                        origin.x: osdPanel.width / 2
                        origin.y: osdPanel.height / 2
                        xScale: root.shouldShowOsd ? 1.0 : 0.4
                        yScale: root.shouldShowOsd ? 1.0 : 0.4

                        Behavior on xScale {
                            PropertyAnimation {
                                duration: root.shouldShowOsd ? 400 : 300
                                easing.type: root.shouldShowOsd ? Easing.OutBack : Easing.InBack
                            }
                        }

                        Behavior on yScale {
                            PropertyAnimation {
                                duration: root.shouldShowOsd ? 400 : 300
                                easing.type: root.shouldShowOsd ? Easing.OutBack : Easing.InBack
                            }
                        }
                    },
                    Translate {
                        y: root.shouldShowOsd ? 0 : 100

                        Behavior on y {
                            PropertyAnimation {
                                duration: root.shouldShowOsd ? 400 : 300
                                easing.type: root.shouldShowOsd ? Easing.OutBack : Easing.InBack
                            }
                        }
                    }
                ]

                SequentialAnimation {
                    id: endWiggle
                    running: false

                    PauseAnimation { duration: 450 }

                    SequentialAnimation {
                        loops: 2
                        PropertyAnimation {
                            target: scaleTransform
                            properties: "xScale,yScale"
                            to: 1.02
                            duration: 100
                            easing.type: Easing.InOutSine
                        }
                        PropertyAnimation {
                            target: scaleTransform
                            properties: "xScale,yScale"
                            to: 1.0
                            duration: 100
                            easing.type: Easing.InOutSine
                        }
                    }
                }

                onVisibleChanged: {
                    if (visible && root.shouldShowOsd)
                        endWiggle.start()
                }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 10
                    }

                    SpeakerIcon {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        muted: root.muted
                        volume: root.volume
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 10
                        radius: 2
                        color: Colors.volumeBarBackground
                        clip: true

                        VolumeBarFill {
                            anchors.fill: parent
                            volume: root.volume
                            muted: root.muted
                            cornerRadius: 2
                        }
                    }
                }
            }
        }
    }
}
