import QtQuick

Item {
    id: root

    property string text: ""
    property color color: "#ffffff"
    property font font: Qt.font({})
    property int gap: 48
    property real pixelsPerSecond: 36
    property int pauseMs: 1200

    clip: true
    implicitHeight: measureText.height

    readonly property bool scroll: measureText.paintedWidth > width && width > 0
    readonly property real travel: measureText.paintedWidth + root.gap

    Text {
        id: measureText
        visible: false
        text: root.text
        font: root.font
    }

    Row {
        id: marqueeRow
        spacing: root.gap

        Repeater {
            model: root.scroll ? 2 : 1

            Text {
                text: root.text
                font: root.font
                color: root.color
            }
        }
    }

    SequentialAnimation {
        id: scrollAnim
        running: root.scroll && root.visible && root.width > 0
        loops: Animation.Infinite

        PauseAnimation { duration: root.pauseMs }

        NumberAnimation {
            target: marqueeRow
            property: "x"
            from: 0
            to: -root.travel
            duration: Math.max(1, root.travel / root.pixelsPerSecond * 1000)
            easing.type: Easing.Linear
        }

        PropertyAction {
            target: marqueeRow
            property: "x"
            value: 0
        }
    }

    function resetScroll() {
        scrollAnim.stop()
        marqueeRow.x = 0
        if (scroll) scrollAnim.start()
    }

    onTextChanged: resetScroll()
    onWidthChanged: resetScroll()
}
