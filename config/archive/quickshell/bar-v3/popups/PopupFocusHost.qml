import QtQuick

FocusScope {
    id: root

    property bool active: false

    signal escapePressed()

    focus: active

    Keys.onEscapePressed: root.escapePressed()
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            root.escapePressed()
            event.accepted = true
        }
    }

    Component.onCompleted: {
        if (active)
            forceActiveFocus()
    }

    onActiveChanged: {
        if (active)
            refocus()
    }

    function refocus() {
        Qt.callLater(() => {
            if (!root.active)
                return
            root.forceActiveFocus()
        })
        refocusTimer.restart()
    }

    Timer {
        id: refocusTimer
        interval: 50
        repeat: false
        onTriggered: {
            if (root.active)
                root.forceActiveFocus()
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 0
        acceptedButtons: Qt.AllButtons
        onClicked: mouse => mouse.accepted = true
        onWheel: wheel => wheel.accepted = true
    }

    default property alias content: contentSlot.data

    Item {
        id: contentSlot
        anchors.fill: parent
        z: 1
    }
}
