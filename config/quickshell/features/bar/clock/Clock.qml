import QtQuick
import qs.shared.theme
import qs.features.bar.music

Item {
    id: clock

    property bool vertical: false
    // Right-click toggles date ↔ now-playing marquee.
    property bool showMusic: false

    signal clicked

    MprisPlaybackSession {
        id: playback
    }

    readonly property string musicText: {
        if (!playback.hasPlayer)
            return "Nothing playing"
        if (playback.artist && playback.artist !== "Unknown artist")
            return playback.title + " · " + playback.artist
        return playback.title
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

    MarqueeText {
        id: musicMarquee

        anchors.centerIn: parent
        width: clock.implicitWidth
        visible: clock.showMusic && !clock.vertical
        text: clock.musicText
        color: Colors.primary
        speed: 28
        gap: 40
        startDelay: 900
        font: Qt.font({
            family: Constants.fontFamily,
            pixelSize: Constants.fontSizeMd,
            weight: Font.Medium
        })
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
