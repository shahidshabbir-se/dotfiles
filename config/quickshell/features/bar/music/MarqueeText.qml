import QtQuick

Item {
    id: root

    property string text: ""
    property color color: "white"
    property font font: Qt.font({
        family: "sans-serif",
        pixelSize: 14
    })

    // Marquee tuning
    property real speed: 32
    property real gap: 48
    property int startDelay: 1800
    property bool active: true
    property bool delayComplete: false

    readonly property bool overflow:
        firstText.implicitWidth > width

    readonly property real loopDistance:
        firstText.implicitWidth + gap

    readonly property int loopDuration:
        Math.max(
            1200,
            Math.round(loopDistance / speed * 1000)
        )

    implicitHeight: firstText.implicitHeight

    clip: true

    onTextChanged: restartMarquee()
    onWidthChanged: restartMarquee()
    onOverflowChanged: restartMarquee()
    onActiveChanged: restartMarquee()

    Component.onCompleted: restartMarquee()

    Timer {
        id: startDelayTimer

        interval: root.startDelay
        repeat: false

        onTriggered: root.delayComplete = true
    }

    function restartMarquee() {
        track.x = 0
        delayComplete = false
        startDelayTimer.stop()

        if (active && overflow)
            startDelayTimer.start()
    }

    Item {
        id: track

        x: 0
        y: 0

        height: root.height

        Text {
            id: firstText

            text: root.text
            color: root.color
            font: root.font

            anchors.verticalCenter: parent.verticalCenter

            /*
             * Centered when the text fits, left-anchored
             * while it is marqueeing.
             */
            width: root.overflow ? implicitWidth : root.width
            horizontalAlignment: root.overflow
                ? Text.AlignLeft
                : Text.AlignHCenter

            textFormat: Text.PlainText
            wrapMode: Text.NoWrap
        }

        /*
         * Duplicate text makes the marquee seamless.
         *
         * While firstText exits on the left,
         * secondText enters from the right.
         */
        Text {
            id: secondText

            visible: root.overflow

            x: firstText.implicitWidth + root.gap

            text: root.text
            color: root.color
            font: root.font

            anchors.verticalCenter: parent.verticalCenter

            textFormat: Text.PlainText
            wrapMode: Text.NoWrap
        }
    }

    /*
     * Continuous right -> left loop.
     *
     * The initial pass is held by startDelayTimer above so the
     * beginning of the title or artist can be read before it moves.
     */
    SequentialAnimation {
        id: marquee

        running: root.active && root.overflow && root.delayComplete
        loops: Animation.Infinite

        NumberAnimation {
            target: track
            property: "x"

            // RIGHT -> LEFT
            from: 0
            to: -root.loopDistance

            duration: root.loopDuration
            easing.type: Easing.Linear
        }

        ScriptAction {
            script: track.x = 0
        }
    }
}
