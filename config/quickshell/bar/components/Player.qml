import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import qs.configuration

Rectangle {
  id: playerModule
  Layout.alignment: Qt.AlignHCenter
  Layout.preferredHeight: 120
  Layout.minimumHeight: 120
  Layout.maximumHeight: 120
  Layout.preferredWidth: 28
  Layout.minimumWidth: 28
  Layout.maximumWidth: 28
  implicitHeight: 120
  implicitWidth: 28
  layer.enabled: true
  radius: innerModulesRadius
  color: Colors.moduleBackground

  HoverHandler { id: hoverHandler }

  border.width: 1
  border.color: (hoverHandler.hovered && !playing) ? Colors.playerBorderHover : Colors.moduleBackground

  Behavior on border.color {
    ColorAnimation { duration: 200 }
  }

  property bool playing: false
  property string artUrl: ''
  property bool menuOpen: false
  property string trackTitle: "Nothing playing"
  property string trackArtist: ""
  property string playerName: "playerctl"
  property var activePlayer: null
  property bool progressDragging: false
  property real progressDragRatio: 0
  readonly property bool hasProgress: activePlayer && activePlayer.positionSupported && activePlayer.length > 0
  readonly property real progressRatio: hasProgress ? Math.max(0, Math.min(1, activePlayer.position / activePlayer.length)) : 0
  readonly property real displayProgressRatio: progressDragging ? progressDragRatio : progressRatio

  function refreshActivePlayer() {
    activePlayer = Mpris.players.values.find(player => player.isPlaying) ?? Mpris.players.values[0] ?? null
  }

  function formatTime(seconds) {
    if (!seconds || seconds < 0) return "0:00"
    const total = Math.floor(seconds)
    const minutes = Math.floor(total / 60)
    const secs = total % 60
    return `${minutes}:${secs.toString().padStart(2, "0")}`
  }

  function seekToProgress(mouseX, barWidth) {
    if (!hasProgress || !activePlayer?.canSeek || barWidth <= 0) return

    progressDragRatio = Math.max(0, Math.min(1, mouseX / barWidth))
    activePlayer.position = activePlayer.length * progressDragRatio
    activePlayer.positionChanged()
  }

  Process { id: playerPrev; running: false; command: [ "playerctl", "previous" ] }
  Process { id: playerPlayPause; running: false; command: [ "playerctl", "play-pause" ] }
  Process { id: playerNext; running: false; command: [ "playerctl", "next" ] }

  Component.onCompleted: refreshActivePlayer()

  Process {
    id: metadataUpdater
    running: true
    command: ["playerctl", "metadata", "--format", "{{playerName}}\u001f{{artist}}\u001f{{title}}"]

    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.includes("\u001f") ? text.split("\u001f") : text.split("\\n")
        playerName = lines[0]?.trim() || "playerctl"
        trackArtist = lines[1]?.trim() || ""
        trackTitle = lines[2]?.trim() || (playing ? "Unknown track" : "Nothing playing")
      }
    }

    stderr: StdioCollector {
      onStreamFinished: {
        if (text.trim().length > 0) {
          trackTitle = "Nothing playing"
          trackArtist = ""
        }
      }
    }
  }

  Process {
    id: statusUpdater
    running: true
    command: [ "playerctl", "status" ]
    stdout: SplitParser {
      onRead: s => {
        if (s === "Playing") {
          playing = true;
          if (artUrl === '') { artUrl = "../svg/player-background.png" }
        } else playing = false
      }
    }

    stderr: SplitParser {
      onRead: err => {
        if (err === "No player could handle this command") {
          artUrl = "../svg/player-background.png"
          playing = false
        }
      }
    }
  }

  Process {
    id: artUrlUpdater
    running: true
    command: [ "playerctl", "metadata", "mpris:artUrl" ]
    stdout: SplitParser {
      onRead: art => {
        if (art && art.trim() !== "") { artUrl = art.trim() }
        else { artUrl = "../svg/player-background.png" }
      }
    }

    stderr: SplitParser {
      onRead: err => {
        if (err === "No player could handle this command") {
          artUrl = "../svg/player-background.png"
        }
      }
    }
  }

  Timer {
    interval: 600
    running: true
    repeat: true
    onTriggered: {
      refreshActivePlayer()
      artUrlUpdater.running = true
      metadataUpdater.running = true
      if (activePlayer && activePlayer.isPlaying) activePlayer.positionChanged()
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: { statusUpdater.running = true }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    cursorShape: Qt.PointingHandCursor

    onWheel: () => {}

    onClicked: (mouse) => {
      if (mouse.button === Qt.LeftButton) { playerModule.menuOpen = !playerModule.menuOpen; }
      else if (mouse.button === Qt.RightButton) { playerNext.running = true; }
      else if (mouse.button === Qt.MiddleButton) { playerPlayPause.running = true; }
    }
  }

  LazyLoader {
    id: playerMenuLoader
    active: playerModule.menuOpen

    Scope {
      PanelWindow {
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"

        MouseArea {
          anchors.fill: parent
          z: 0
          onClicked: playerModule.menuOpen = false
        }
      }

      PanelWindow {
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        anchors.left: true
        anchors.bottom: true
        margins.left: 60
        margins.bottom: 34
        implicitWidth: 400
        implicitHeight: 190
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell_player_popup"

        Rectangle {
          id: playerMenuBackground
          anchors.fill: parent
          radius: 6
          color: Colors.popoutBackground
          border.width: 0
          clip: true

          MouseArea {
            anchors.fill: parent
            z: 0
            acceptedButtons: Qt.AllButtons
            onClicked: mouse => mouse.accepted = true
            onWheel: wheel => wheel.accepted = true
          }

          RowLayout {
            z: 1
            anchors.fill: parent
            anchors.margins: 14
            spacing: 14

            Rectangle {
              Layout.preferredWidth: 162
              Layout.minimumWidth: 162
              Layout.maximumWidth: 162
              Layout.preferredHeight: 162
              Layout.minimumHeight: 162
              Layout.maximumHeight: 162
              Layout.alignment: Qt.AlignVCenter
              radius: 5
              color: Colors.moduleBackground
              clip: true

              Image {
                anchors.fill: parent
                source: artUrl || "../svg/player-background.png"
                sourceSize.width: 162
                sourceSize.height: 162
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
              }
            }

            ColumnLayout {
              Layout.preferredWidth: 196
              Layout.minimumWidth: 196
              Layout.maximumWidth: 196
              Layout.fillWidth: true
              Layout.preferredHeight: 162
              Layout.minimumHeight: 162
              Layout.maximumHeight: 162
              spacing: 6

              Text {
                Layout.fillWidth: true
                Layout.preferredHeight: 18
                Layout.minimumHeight: 18
                Layout.maximumHeight: 18
                text: playerName.toUpperCase()
                color: Colors.workspaceActive
                elide: Text.ElideRight
                font.family: "Cartograph CF"
                font.italic: true
                font.pixelSize: 12
              }

              Text {
                Layout.fillWidth: true
                Layout.preferredHeight: 24
                Layout.minimumHeight: 24
                Layout.maximumHeight: 24
                text: trackTitle
                color: Colors.textPrimary
                wrapMode: Text.NoWrap
                maximumLineCount: 1
                elide: Text.ElideRight
                font.family: "Cartograph CF"
                font.italic: true
                font.pixelSize: 16
              }

              Text {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                Layout.minimumHeight: 30
                Layout.maximumHeight: 30
                text: trackArtist || (playing ? "Unknown artist" : "No active media")
                color: Colors.textSecondary
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                font.family: "Cartograph CF"
                font.italic: true
                font.pixelSize: 13
              }

              ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 31
                Layout.minimumHeight: 31
                Layout.maximumHeight: 31
                spacing: 4

                RowLayout {
                  Layout.fillWidth: true

                  Text {
                    text: formatTime(activePlayer?.position ?? 0)
                    color: Colors.textSecondary
                    font.family: "Cartograph CF"
                    font.italic: true
                    font.pixelSize: 9
                  }

                  Item { Layout.fillWidth: true }

                  Text {
                    text: formatTime(activePlayer?.length ?? 0)
                    color: Colors.textSecondary
                    font.family: "Cartograph CF"
                    font.italic: true
                    font.pixelSize: 9
                  }
                }

                Rectangle {
                  id: progressBar
                  Layout.fillWidth: true
                  height: 6
                  radius: 2
                  color: Colors.volumeBarBackground
                  opacity: hasProgress ? 1 : 0.45

                  Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * displayProgressRatio
                    radius: parent.radius

                    gradient: Gradient {
                      orientation: Gradient.Horizontal
                      GradientStop { position: 0; color: Colors.volumeGradientStart }
                      GradientStop { position: 1; color: Colors.volumeGradientEnd }
                    }

                    Behavior on width {
                      NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                    }
                  }

                  Rectangle {
                    id: progressThumb
                    width: 13
                    height: 13
                    radius: 7
                    visible: hasProgress
                    x: Math.max(0, Math.min(progressBar.width - width, (progressBar.width * displayProgressRatio) - (width / 2)))
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.textPrimary
                    border.width: 2
                    border.color: Colors.volumeGradientEnd
                  }

                  MouseArea {
                    id: progressHitArea
                    anchors.fill: parent
                    anchors.margins: -8
                    z: 2
                    cursorShape: hasProgress && activePlayer?.canSeek ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onPressed: mouse => {
                      mouse.accepted = true
                      progressDragging = true
                      seekToProgress(mouse.x + progressHitArea.x, progressBar.width)
                    }
                    onPositionChanged: mouse => {
                      if (progressDragging) seekToProgress(mouse.x + progressHitArea.x, progressBar.width)
                    }
                    onReleased: mouse => {
                      mouse.accepted = true
                      seekToProgress(mouse.x + progressHitArea.x, progressBar.width)
                      progressDragging = false
                    }
                    onCanceled: progressDragging = false
                    onClicked: mouse => {
                      mouse.accepted = true
                    }
                    onWheel: wheel => {
                      wheel.accepted = true
                      if (activePlayer?.canSeek) {
                        activePlayer.seek(wheel.angleDelta.y > 0 ? 5 : -5)
                        activePlayer.positionChanged()
                      }
                    }
                  }
                }
              }

              Item { Layout.fillHeight: true }

              RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 32
                Layout.minimumHeight: 32
                Layout.maximumHeight: 32
                spacing: 7

                Repeater {
                  model: [
                    { icon: "../svg/previous.svg", run: () => playerPrev.running = true },
                    { icon: playing ? "../svg/pause.svg" : "../svg/play.svg", run: () => playerPlayPause.running = true },
                    { icon: "../svg/next.svg", run: () => playerNext.running = true },
                  ]

                  Rectangle {
                    required property var modelData
                    width: 42
                    height: 30
                    radius: 3
                    color: controlHover.hovered ? Colors.playerBorderHover : Colors.moduleBackground
                    border.width: 1
                    border.color: controlHover.hovered ? Colors.moduleBorderHover : Colors.moduleBorder

                    HoverHandler { id: controlHover }

                    Image {
                      anchors.centerIn: parent
                      width: 17
                      height: 17
                      source: modelData.icon
                      sourceSize.width: 28
                      sourceSize.height: 28
                      fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                      anchors.fill: parent
                      z: 2
                      cursorShape: Qt.PointingHandCursor
                      onClicked: mouse => {
                        mouse.accepted = true
                        modelData.run()
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  Rectangle {
    id: gradientBorder
    anchors.fill: parent
    radius: parent.radius
    visible: playing
    opacity: hoverHandler.hovered ? 1 : 0

    Behavior on opacity {
      NumberAnimation {
        duration: 300
      }
    }

    gradient: Gradient {
      GradientStop { position: 0.6; color: Colors.playerGradientStart }
      GradientStop { position: 1.0; color: Colors.playerGradientEnd }
    }

    Rectangle {
      anchors.fill: parent
      anchors.margins: 1
      radius: parent.radius
      color: "#171F24"
    }
  }

  Rectangle {
    id: topHalf
    anchors.top: parent.top
    anchors.topMargin: 1
    anchors.left: parent.left
    anchors.leftMargin: 1
    anchors.right: parent.right
    anchors.rightMargin: 1
    height: 96
    clip: true

    Image {
      anchors.fill: parent
      source: artUrl && artUrl.length > 0 ? artUrl : "../svg/player-background.png"
      sourceSize.width: 96
      sourceSize.height: 96
      fillMode: Image.PreserveAspectCrop
      horizontalAlignment: Image.AlignHCenter
      verticalAlignment: Image.AlignVCenter
      asynchronous: true
      cache: false

      Rectangle {
        anchors.fill: parent
        gradient: Gradient {
          GradientStop { position: 0.3; color: "#00000000" }
          GradientStop { position: 0.95; color: (hoverHandler.hovered) ? "#111A1F" : "#131B1F" }
        }
      }
    }

    layer.enabled: true
    layer.effect: OpacityMask {
      maskSource: Rectangle {
        width: topHalf.width
        height: topHalf.height
        radius: topHalf.height > playerModule.radius ? playerModule.radius : 0
      }
    }
  }

  Rectangle {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 1
    height: 26
    width: 26
    radius: playerModule.radius
    color: (hoverHandler.hovered && !playing) ? "#02BC83E3" : "#111A1F"

    Image {
      anchors.centerIn: parent
      width: 18
      height: 18
      source: "../svg/headphones.svg"
      sourceSize.width: 36
      sourceSize.height: 36
    }
  }
}
