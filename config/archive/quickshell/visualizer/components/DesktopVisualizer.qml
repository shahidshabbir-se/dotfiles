import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.configuration

Scope {
  id: root

  property int bandCount: 66
  property int maxValue: 7
  property int barSpacing: 2
  property int barWidth: 5
  property real minPlayingHeight: 3
  property real barOpacity: 0.95
  property color barColor: Colors.visualizerColor
  property bool mediaPlaying: false
  property var values: Array(root.bandCount).fill(0)

  readonly property int clusterWidth: (root.bandCount * root.barWidth) + ((root.bandCount - 1) * root.barSpacing)

  function emptyValues() {
    return Array(root.bandCount).fill(0)
  }

  function parseLevels(raw) {
    const digits = raw.replace(/[^0-7]/g, "")
    if (digits.length === 0) return emptyValues()

    const parsed = digits
      .slice(0, root.bandCount)
      .split("")
      .map(digit => parseInt(digit, 10))

    while (parsed.length < root.bandCount) parsed.push(0)

    return parsed
  }

  function updatePlaybackState() {
    mediaPlaying = Mpris.players.values.some(player => player && player.isPlaying)
  }

  PanelWindow {
    id: visualizerWindow
    aboveWindows: false
    exclusionMode: ExclusionMode.Ignore
    anchors { left: true; right: true; bottom: true }
    margins { left: 72; right: 72; bottom: 9 }
    implicitHeight: 48
    color: "transparent"

    Component.onCompleted: root.updatePlaybackState()

    Timer {
      interval: 600
      running: true
      repeat: true
      onTriggered: root.updatePlaybackState()
    }

    Process {
      id: cavaProcess
      running: true
      command: ["sh", `${Quickshell.shellDir}/scripts/cava-visualizer.sh`]

      stdout: SplitParser {
        onRead: line => {
          root.values = root.parseLevels(line)
        }
      }

      onExited: {
        root.values = root.emptyValues()
      }
    }

    Item {
      anchors.fill: parent

      Row {
        id: visualizerCluster
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: Math.min(parent.width, root.clusterWidth)
        height: parent.height
        spacing: root.barSpacing

        Repeater {
          model: root.bandCount

          Item {
            required property int index
            readonly property real rawRatio: Math.max(0, Math.min(1, (root.values[index] ?? 0) / root.maxValue))
            readonly property real ratio: Math.pow(rawRatio, 0.8)

            width: root.barWidth
            height: visualizerCluster.height

            Rectangle {
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.bottom: parent.bottom
              height: root.mediaPlaying ? Math.max(root.minPlayingHeight, parent.height * ratio) : 0
              radius: width / 2
              antialiasing: false
              opacity: root.mediaPlaying ? root.barOpacity : 0
              color: root.barColor

              Behavior on height {
                NumberAnimation { duration: 70; easing.type: Easing.OutCubic }
              }
            }
          }
        }
      }
    }
  }
}
