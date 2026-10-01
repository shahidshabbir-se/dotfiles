pragma ComponentBehavior: Bound

import QtQuick
import qs.shared.theme

// One input device in the INPUT section. Sibling of SinkRow.
Item {
    id: root

    required property var audio
    required property var node
    required property int rowIndex

    readonly property bool isActive: !!audio.source && !!node && audio.source.id === node.id
    readonly property bool hasCursor: audio.cursorActive
        && audio.focusSection === "input"
        && audio.selectedIndex === rowIndex

    implicitHeight: Constants.buttonSize + Constants.spacingSm

    onHasCursorChanged: if (hasCursor) audio.ensureCursorVisible(root)

    Rectangle {
        anchors.fill: parent
        radius: Constants.buttonRadius
        color: root.hasCursor
            ? Tokens.withAlpha(Colors.primary, 0.16)
            : (root.isActive
                ? (rowArea.containsMouse ? Tokens.withAlpha(Colors.primary, 0.18) : Tokens.withAlpha(Colors.primary, 0.10))
                : (rowArea.containsMouse ? Colors.surfaceContainerHigh : "transparent"))
        border.width: root.hasCursor ? Constants.borderWidth : 0
        border.color: Tokens.withAlpha(Colors.primary, 0.5)

        Behavior on color {
            ColorAnimation { duration: Constants.animationFast }
        }
    }

    Text {
        id: glyph

        anchors.left: parent.left
        anchors.leftMargin: Constants.paddingMd
        anchors.verticalCenter: parent.verticalCenter
        width: 20
        horizontalAlignment: Text.AlignHCenter
        text: AudioLabels.sourceGlyph(root.node)
        textFormat: Text.PlainText
        color: Colors.surfaceForeground
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Constants.iconSizeLg + 2
    }

    Text {
        anchors.left: glyph.right
        anchors.leftMargin: Constants.spacingMd
        anchors.right: percent.left
        anchors.rightMargin: Constants.spacingMd
        anchors.verticalCenter: parent.verticalCenter
        text: AudioLabels.nodeLabel(root.node)
        textFormat: Text.PlainText
        elide: Text.ElideRight
        color: Colors.surfaceForeground
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeSm
        font.weight: root.isActive ? Font.DemiBold : Font.Medium
    }

    Text {
        id: percent

        anchors.right: parent.right
        anchors.rightMargin: Constants.paddingMd
        anchors.verticalCenter: parent.verticalCenter
        text: root.isActive ? "ACTIVE" : ""
        textFormat: Text.PlainText
        color: root.isActive ? Colors.primary : "transparent"
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeXs
        font.weight: Font.DemiBold
        font.letterSpacing: 0.8
    }

    MouseArea {
        id: rowArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: {
            if (containsMouse)
                root.audio.cursorActive = false
        }
        onClicked: root.audio.setDefaultSource(root.node)
    }
}
