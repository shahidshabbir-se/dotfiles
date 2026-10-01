pragma ComponentBehavior: Bound

import QtQuick
import qs.shared.theme

// One per-app playback stream in the SOURCES section. The stream carries its own
// slider, so h/l adjusts this stream's level while the cursor is on the row and
// m / Enter mute it.
Item {
    id: root

    required property var audio
    required property var node
    required property int rowIndex

    readonly property bool muted: !!node && !!node.audio && node.audio.muted
    readonly property real volume: node && node.audio ? node.audio.volume : 0
    // The stream that is playing right now is marked, so the list reads as
    // "what is making noise" rather than "what exists".
    readonly property bool isActive: audio.streamRepresentsPlayer(node, audio.activePlayer)
    readonly property bool hasCursor: audio.cursorActive
        && audio.focusSection === "streams"
        && audio.selectedIndex === rowIndex

    implicitHeight: header.implicitHeight + Constants.spacingSm * 2 + slider.implicitHeight

    onHasCursorChanged: if (hasCursor) audio.ensureCursorVisible(root)

    Rectangle {
        anchors.fill: parent
        radius: Constants.buttonRadius
        color: root.hasCursor
            ? Tokens.withAlpha(Colors.primary, 0.16)
            : (root.isActive
                ? Tokens.withAlpha(Colors.primary, 0.10)
                : (rowArea.containsMouse ? Colors.surfaceContainerHigh : "transparent"))
        border.width: root.hasCursor ? Constants.borderWidth : 0
        border.color: Tokens.withAlpha(Colors.primary, 0.5)

        Behavior on color {
            ColorAnimation { duration: Constants.animationFast }
        }
    }

    Row {
        id: header

        anchors.left: parent.left
        anchors.leftMargin: Constants.paddingMd
        anchors.right: parent.right
        anchors.rightMargin: Constants.paddingMd
        anchors.top: parent.top
        anchors.topMargin: Constants.spacingSm
        spacing: Constants.spacingMd

        Text {
            id: muteIcon

            anchors.verticalCenter: parent.verticalCenter
            width: 20
            horizontalAlignment: Text.AlignHCenter
            text: root.muted ? "󰝟" : "󰕾"
            textFormat: Text.PlainText
            opacity: root.muted ? 0.5 : 1
            color: Colors.surfaceForeground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Constants.iconSizeLg + 2

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.audio.toggleStreamMute(root.node)
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: header.width - muteIcon.width - percent.width - Constants.spacingMd * 2
            text: root.audio.streamLabel(root.node)
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: Colors.surfaceForeground
            font.family: Constants.fontFamily
            font.pixelSize: Constants.fontSizeSm
            font.weight: root.isActive ? Font.DemiBold : Font.Medium
        }

        Text {
            id: percent

            anchors.verticalCenter: parent.verticalCenter
            width: 34
            horizontalAlignment: Text.AlignRight
            text: Math.round(root.volume * 100) + "%"
            textFormat: Text.PlainText
            opacity: root.muted ? 0.5 : 1
            color: root.isActive ? Colors.primary : Colors.surfaceVariantForeground
            font.family: Constants.fontFamily
            font.pixelSize: Constants.fontSizeXs
            font.weight: Font.DemiBold
        }
    }

    AudioSlider {
        id: slider

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Constants.paddingMd + 20 + Constants.spacingMd
        anchors.rightMargin: Constants.paddingMd
        anchors.top: header.bottom
        anchors.topMargin: Constants.spacingSm
        minimum: 0
        // Streams may be pushed past unity gain; sinks and sources may not.
        maximum: 1.5
        step: 0.05
        value: root.volume
        dimmed: root.muted
        interactive: !!root.node && !!root.node.audio
        onMoved: function(value) {
            if (root.node && root.node.audio)
                root.node.audio.volume = value
        }
        onToggleMute: root.audio.toggleStreamMute(root.node)
    }

    // Behind the mute icon and the slider, so those two still get their clicks.
    MouseArea {
        id: rowArea

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        onContainsMouseChanged: {
            if (containsMouse)
                root.audio.cursorActive = false
        }
    }
}
