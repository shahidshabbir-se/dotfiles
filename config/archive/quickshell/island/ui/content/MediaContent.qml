import QtQuick
import Qt5Compat.GraphicalEffects
import "../../config" as Config

FocusScope {
    id: root

    required property var contentModel
    required property var palette

    signal actionRequested(string action, var argument)

    focus: true

    Keys.onEscapePressed: root.actionRequested("dismiss", null)

    Component.onCompleted: focusTimer.restart()

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: root.forceActiveFocus()
    }

    readonly property real preferredWidth: Config.IslandConstants.mediaWidth
    readonly property real preferredHeight: Config.IslandConstants.mediaHeight
    property real elapsed: 0
    property bool seeking: false
    property real seekProgress: 0
    property real pendingSeekProgress: -1
    readonly property real total: Math.max(0, contentModel?.player?.length ?? 0)
    readonly property real progress: total > 0 ? Math.min(1, elapsed / total) : 0
    readonly property bool seekable: (contentModel?.player?.canSeek ?? false)
        && (contentModel?.player?.positionSupported ?? false)
        && (contentModel?.player?.lengthSupported ?? false)
        && total > 0
    readonly property real displayProgress: seeking
        ? seekProgress
        : pendingSeekProgress >= 0
            ? pendingSeekProgress
            : progress
    readonly property real displayElapsed: total > 0 ? displayProgress * total : elapsed

    onContentModelChanged: {
        seeking = false
        pendingSeekProgress = -1
        seekSettleTimer.stop()
    }

    function updateSeekProgress(pointerX, availableWidth) {
        seekProgress = Math.max(0, Math.min(1, pointerX / Math.max(1, availableWidth)))
    }

    function formatTime(seconds) {
        const value = Math.max(0, Math.floor(seconds || 0))
        return Math.floor(value / 60) + ":" + String(value % 60).padStart(2, "0")
    }

    function capitalizeFirst(value) {
        const text = String(value ?? "")
        return text ? text.charAt(0).toUpperCase() + text.slice(1) : ""
    }

    Timer {
        interval: Config.IslandConstants.mediaProgressPollInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.elapsed = root.contentModel?.player?.position ?? 0
            if (root.pendingSeekProgress >= 0 && root.total > 0) {
                const actualProgress = root.elapsed / root.total
                if (Math.abs(actualProgress - root.pendingSeekProgress) < 0.025) {
                    root.pendingSeekProgress = -1
                    seekSettleTimer.stop()
                }
            }
        }
    }

    Timer {
        id: seekSettleTimer
        interval: Config.IslandConstants.mediaSeekSettleInterval
        onTriggered: root.pendingSeekProgress = -1
    }

    Rectangle {
        id: artFrame
        x: Config.IslandConstants.mediaPadding
        y: Config.IslandConstants.mediaPadding
        width: Config.IslandConstants.mediaArtSize
        height: Config.IslandConstants.mediaArtSize
        radius: Config.IslandConstants.mediaArtRadius
        clip: true
        color: root.palette.surfaceContainerHigh
        layer.enabled: true
        layer.smooth: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: artFrame.width
                height: artFrame.height
                radius: artFrame.radius
            }
        }

        Image {
            id: albumArt
            anchors.fill: parent
            source: root.contentModel?.artUrl ?? ""
            sourceSize: Qt.size(
                Config.IslandConstants.mediaArtSize * 2,
                Config.IslandConstants.mediaArtSize * 2
            )
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            visible: status === Image.Ready
        }

        Text {
            anchors.centerIn: parent
            visible: albumArt.status !== Image.Ready
            text: Config.IslandConstants.mediaIcon
            color: root.palette.surfaceForeground
            font.family: Config.IslandConstants.iconFontFamily
            font.pixelSize: 24
        }
    }

    Column {
        x: Config.IslandConstants.mediaPadding + Config.IslandConstants.mediaArtSize + 14
        y: Config.IslandConstants.mediaPadding
        width: 222
        spacing: 3

        Text {
            width: parent.width
            text: root.capitalizeFirst(
                root.contentModel?.title || root.contentModel?.stateLabel || "Media"
            )
            color: root.palette.surfaceForeground
            font.family: Config.IslandConstants.textFontFamily
            font.pixelSize: Config.IslandConstants.bodyFontSize
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }
        Text {
            width: parent.width
            text: root.contentModel?.artist || root.contentModel?.stateLabel || ""
            color: root.palette.surfaceVariantForeground
            font.family: Config.IslandConstants.textFontFamily
            font.pixelSize: 13
            elide: Text.ElideRight
        }
    }

    Row {
        id: visualizer
        x: 330
        y: 34
        width: 60
        height: 32
        spacing: 5

        Repeater {
            model: 5

            Rectangle {
                required property int index
                width: 8
                height: root.contentModel?.playing ? 10 + ((index * 7) % 20) : 5
                anchors.bottom: parent.bottom
                radius: Config.Radius.sm
                color: root.palette.primary

                SequentialAnimation on height {
                    running: root.contentModel?.playing ?? false
                    loops: Animation.Infinite
                    NumberAnimation { to: 28; duration: 260 + index * 35; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 8; duration: 300 + index * 25; easing.type: Easing.InOutQuad }
                }
                Behavior on height {
                    enabled: !(root.contentModel?.playing ?? false)
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    Row {
        x: Config.IslandConstants.mediaPadding
        y: 90
        width: 370
        height: 14
        spacing: 10

        Text {
            width: 34
            text: root.formatTime(root.displayElapsed)
            color: root.palette.surfaceVariantForeground
            font.family: Config.IslandConstants.textFontFamily
            font.pixelSize: 10
        }
        Item {
            width: 282
            height: 14
            Rectangle {
                id: progressTrack
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: Config.IslandConstants.mediaProgressHeight
                radius: Config.Radius.xs
                color: root.palette.surfaceContainerHighest
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width * root.displayProgress
                height: Config.IslandConstants.mediaProgressHeight
                radius: Config.Radius.xs
                color: root.palette.primary
            }
            Rectangle {
                width: Config.IslandConstants.mediaProgressThumbSize
                height: width
                radius: Config.Radius.circle(width)
                x: Math.max(0, Math.min(
                    parent.width - width,
                    parent.width * root.displayProgress - width / 2
                ))
                anchors.verticalCenter: parent.verticalCenter
                color: root.palette.surfaceForeground

                Behavior on x {
                    enabled: !root.seeking
                    NumberAnimation {
                        duration: Config.IslandConstants.mediaProgressPollInterval
                        easing.type: Easing.Linear
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                enabled: root.seekable
                preventStealing: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                onPressed: mouse => {
                    root.seeking = true
                    root.updateSeekProgress(mouse.x, width)
                    mouse.accepted = true
                }
                onPositionChanged: mouse => {
                    if (pressed)
                        root.updateSeekProgress(mouse.x, width)
                }
                onReleased: mouse => {
                    root.updateSeekProgress(mouse.x, width)
                    root.pendingSeekProgress = root.seekProgress
                    root.actionRequested("seek", root.seekProgress)
                    root.seeking = false
                    seekSettleTimer.restart()
                }
                onCanceled: {
                    root.seeking = false
                    root.pendingSeekProgress = -1
                }
            }
        }
        Text {
            width: 34
            text: root.formatTime(root.total)
            color: root.palette.surfaceVariantForeground
            font.family: Config.IslandConstants.textFontFamily
            font.pixelSize: 10
            horizontalAlignment: Text.AlignRight
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 112
        height: 33
        spacing: 24

        MediaButton { icon: Config.IslandConstants.previousIcon; onTapped: root.actionRequested("previous", null) }
        MediaButton {
            icon: root.contentModel?.playing
                ? Config.IslandConstants.pauseIcon
                : Config.IslandConstants.playIcon
            prominent: true
            onTapped: root.actionRequested("toggle", null)
        }
        MediaButton { icon: Config.IslandConstants.nextIcon; onTapped: root.actionRequested("next", null) }
    }

    component MediaButton: Rectangle {
        id: button
        required property string icon
        property bool prominent: false
        signal tapped()

        width: prominent ? 34 : 28
        height: width
        radius: Config.Radius.circle(width)
        color: prominent ? root.palette.primaryContainer : "transparent"

        Text {
            anchors.centerIn: parent
            text: button.icon
            color: button.prominent
                ? root.palette.primaryContainerForeground
                : root.palette.surfaceForeground
            font.family: Config.IslandConstants.iconFontFamily
            font.pixelSize: button.prominent ? 15 : 14
        }
        TapHandler { onTapped: button.tapped() }
        HoverHandler { cursorShape: Qt.PointingHandCursor }
    }
}
