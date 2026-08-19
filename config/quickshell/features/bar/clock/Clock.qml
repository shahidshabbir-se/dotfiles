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

    // Horizontal now-playing (no MarqueeText — that type lives under music/).
    Text {
        id: musicMarquee

        anchors.centerIn: parent
        width: clock.implicitWidth
        visible: clock.showMusic && !clock.vertical
        text: clock.musicText
        color: Colors.primary
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.PlainText
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeMd
        font.weight: Font.Medium
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
