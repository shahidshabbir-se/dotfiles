import QtQuick
import qs.shared.theme

Text {
    id: clock

    property bool vertical: false
    signal clicked

    color: Colors.surfaceForeground
    horizontalAlignment: Text.AlignHCenter

    font {
        family: Constants.fontFamily
        pixelSize: vertical ? Constants.fontSizeSm : Constants.fontSizeMd
        weight: Font.Medium
    }

    function updateTime() {
        text = Qt.formatDateTime(new Date(), vertical ? "MMM\nd\nh:mm\nap" : "ddd, MMM d · h:mm ap")
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
        cursorShape: Qt.PointingHandCursor

        onClicked: clock.clicked()
    }
}
