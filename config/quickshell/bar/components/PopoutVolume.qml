import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import qs.configuration

Scope {
  id: root

  property string username: ""

  Process {
    command: ["whoami"]
    running: true
    stdout: SplitParser { onRead: name => username = name }
  }

  readonly property PwNode sink: Pipewire.defaultAudioSink
  property bool muted: sink?.audio?.muted ?? false
  property real volume: sink?.audio?.volume ?? 0
  property bool shouldShowOsd: false

  // Bind the pipewire node so its volume will be tracked
  PwObjectTracker {
    objects: [ Pipewire.defaultAudioSink ]
  }

  Connections {
    target: Pipewire.defaultAudioSink?.audio

    function onVolumeChanged() {
      root.shouldShowOsd = true;
      hideTimer.restart();
    }
  }

  Timer {
    id: hideTimer
    interval: 1000
    onTriggered: root.shouldShowOsd = false
  }

  LazyLoader {
    id: popoutVolume
    active: root.shouldShowOsd

    PanelWindow {
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.namespace: "quickshell_volume_osd"
      anchors.bottom: true
      margins.bottom: screen.height / 12

      implicitWidth: 200
      implicitHeight: 36
      color: "transparent"

      MouseArea {
        anchors.fill: parent

        onClicked: { sink.audio.muted = !muted; }

        onWheel: wheel => {
          if (sink && !muted) {
            let delta = wheel.angleDelta.y > 0 ? 0.1 : -0.1
            let newVolume = volume + delta
            newVolume = Math.max(0, Math.min(1, newVolume))
            sink.audio.volume = newVolume
          }
        }
      }

      Rectangle {
        id: mainRect
        anchors.fill: parent
        radius: 4
        color: Colors.popoutBackground

        border.width: 0
        border.color: Colors.popoutBorder

        property real yOffset: 0

        transform: [
          Scale {
            id: scaleTransform
            origin.x: mainRect.width / 2
            origin.y: mainRect.height / 2
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
            id: translateTransform
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
              to: 1.05
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
          if (visible && root.shouldShowOsd) {
            endWiggle.start()
          }
        }

        RowLayout {
          anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 15
          }

          Image {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            source: `../svg/${muted ? 'speaker-dark' : 'speaker'}.svg`
            opacity: muted ? 0.6 : 1.0
          }

          Rectangle {
            color: Colors.volumeBarBackground
            Layout.fillWidth: true
            implicitHeight: 10
            radius: 2

            Rectangle {
              radius: 2
              anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
              }
              gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: Colors.volumeGradientStart }
                GradientStop { position: 1; color: Colors.volumeGradientEnd }
              }

              width: {
                let len = muted ? 1 : parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0);
                return Math.min(len, parent.width);
              }

              Behavior on width {
                PropertyAnimation {
                  duration: 150
                  easing.type: Easing.OutQuad
                }
              }
            }
          }
        }
      }
    }
  }
}
