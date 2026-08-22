import QtQuick
import Quickshell.Services.Mpris
import qs.shared.theme

Item {
    id: clock

    property bool vertical: false
    // Right-click toggles date ↔ now-playing marquee.
    property bool showMusic: false

    signal clicked

    // Minimal MPRIS reader — Clock can't import qs.features.bar (circular).
    readonly property var player: {
        let fallback = null
        for (let i = 0; i < Mpris.players.values.length; i++) {
            const candidate = Mpris.players.values[i]
            if (candidate.isPlaying)
                return candidate
            if (!fallback || candidate.identity.toLowerCase().includes("spotify"))
                fallback = candidate
        }
        return fallback
    }
    readonly property bool hasPlayer: player !== null
    readonly property string trackTitle: hasPlayer
        ? (player.trackTitle || "Unknown title")
        : "Nothing playing"
    readonly property string trackArtist: hasPlayer
        ? (player.trackArtist || "")
        : ""

    readonly property string musicText: {
        if (!clock.hasPlayer)
            return "Nothing playing"
        if (clock.trackArtist && clock.trackArtist !== "Unknown artist")
            return clock.trackTitle + " · " + clock.trackArtist
        return clock.trackTitle
    }

    // Keep width stable when switching date ↔ marquee (date as baseline).
    implicitWidth: vertical
        ? Math.max(dateLabel.implicitWidth, 48)
        : Math.max(dateLabel.implicitWidth, 160)
    implicitHeight: vertical
        ? (showMusic ? verticalMusic.implicitHeight : dateLabel.implicitHeight)
        : Math.max(dateLabel.implicitHeight, musicMarquee.implicitHeight)

    Text {
        id: dateLabel

        anchors.centerIn: parent
        visible: !clock.showMusic
        color: Colors.surfaceForeground
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.PlainText

        font {
            family: Constants.fontFamily
            pixelSize: clock.vertical ? Constants.fontSizeSm : Constants.fontSizeMd
            weight: Font.Medium
        }
    }

    // Inline marquee — music/MarqueeText isn't visible from clock/ (qmldir).
    Item {
        id: musicMarquee

        anchors.centerIn: parent
        width: clock.implicitWidth
        height: firstText.implicitHeight
        visible: clock.showMusic && !clock.vertical
        clip: true

        readonly property real speed: 28
        readonly property real gap: 40
        readonly property bool overflow: firstText.implicitWidth > width
        readonly property real loopDistance: firstText.implicitWidth + gap
        readonly property int loopDuration: Math.max(
            1200,
            Math.round(loopDistance / speed * 1000)
        )
        property bool delayComplete: false

        function restart() {
            track.x = 0
            delayComplete = false
            startDelay.stop()
            if (visible && overflow)
                startDelay.start()
        }

        onVisibleChanged: restart()
        onWidthChanged: restart()
        onOverflowChanged: restart()

        Connections {
            target: clock
            function onMusicTextChanged() { musicMarquee.restart() }
        }

        Timer {
            id: startDelay
            interval: 900
            repeat: false
            onTriggered: musicMarquee.delayComplete = true
        }

        Item {
            id: track
            height: parent.height

            Text {
                id: firstText
                text: clock.musicText
                color: Colors.primary
                font.family: Constants.fontFamily
                font.pixelSize: Constants.fontSizeMd
                font.weight: Font.Medium
                textFormat: Text.PlainText
                wrapMode: Text.NoWrap
                anchors.verticalCenter: parent.verticalCenter
                width: musicMarquee.overflow ? implicitWidth : musicMarquee.width
                horizontalAlignment: musicMarquee.overflow
                    ? Text.AlignLeft
                    : Text.AlignHCenter
            }

            Text {
                visible: musicMarquee.overflow
                x: firstText.implicitWidth + musicMarquee.gap
                text: clock.musicText
                color: Colors.primary
                font.family: Constants.fontFamily
                font.pixelSize: Constants.fontSizeMd
                font.weight: Font.Medium
                textFormat: Text.PlainText
                wrapMode: Text.NoWrap
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        SequentialAnimation {
            running: musicMarquee.visible
                && musicMarquee.overflow
                && musicMarquee.delayComplete
            loops: Animation.Infinite

            NumberAnimation {
                target: track
                property: "x"
                from: 0
                to: -musicMarquee.loopDistance
                duration: musicMarquee.loopDuration
                easing.type: Easing.Linear
            }

            ScriptAction {
                script: track.x = 0
            }
        }
    }

    // Vertical bar: no horizontal marquee room — wrap/elide.
    Text {
        id: verticalMusic

        anchors.centerIn: parent
        width: parent.width
        visible: clock.showMusic && clock.vertical
        text: clock.musicText
        color: Colors.primary
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        maximumLineCount: 4
        textFormat: Text.PlainText

        font {
            family: Constants.fontFamily
            pixelSize: Constants.fontSizeSm
            weight: Font.Medium
        }
    }

    function updateTime() {
        dateLabel.text = Qt.formatDateTime(
            new Date(),
            vertical ? "MMM\nd\nh:mm\nap" : "ddd, MMM d · h:mm ap"
        )
    }

    onVerticalChanged: updateTime()
    Component.onCompleted: updateTime()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.updateTime()
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: event => {
            if (event.button === Qt.RightButton) {
                clock.showMusic = !clock.showMusic
                event.accepted = true
                return
            }
            clock.clicked()
        }
    }
}
