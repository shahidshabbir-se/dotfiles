import QtQuick
import "../../config" as Config

Item {
    id: root

    required property var contentModel
    required property var palette
    required property bool expanded

    signal expandedRequested(bool value)
    signal actionRequested(string action)

    readonly property int minimumWidth: Config.IslandConstants.notificationMinimumWidth
    readonly property int compactMaximumWidth: Config.IslandConstants.notificationCompactMaximumWidth
    readonly property int expandedMaximumWidth: Config.IslandConstants.notificationExpandedMaximumWidth
    readonly property int iconSlotWidth: Config.IslandConstants.notificationIconSlotWidth
    readonly property int contentSpacing: Config.IslandConstants.notificationContentSpacing
    readonly property int horizontalPadding: Config.IslandConstants.notificationHorizontalPadding
    readonly property int compactVerticalPadding: Config.IslandConstants.notificationCompactVerticalPadding
    readonly property int expandedVerticalPadding: Config.IslandConstants.notificationExpandedVerticalPadding
    readonly property int compactTextWidth: compactMaximumWidth - horizontalPadding * 2
        - iconSlotWidth - contentSpacing
        - Config.IslandConstants.notificationDismissSize - contentSpacing
    readonly property int expandedTextWidth: expandedMaximumWidth - horizontalPadding * 2
        - iconSlotWidth - contentSpacing
        - Config.IslandConstants.notificationDismissSize - contentSpacing
    readonly property string notificationText: {
        const summary = contentModel?.summary ?? ""
        const body = contentModel?.body ?? ""
        if (summary && body && body !== summary)
            return summary + "  " + body
        return summary || body || "New notification"
    }
    readonly property bool prefersWrap: metrics.advanceWidth > compactTextWidth
    readonly property bool hasOverflow: compactProbe.lineCount > 2
        || metrics.advanceWidth > compactTextWidth * 2
        || (metrics.advanceWidth > compactTextWidth && compactProbe.lineCount <= 1)
    readonly property real compactWidth: prefersWrap
        ? compactMaximumWidth
        : Math.max(
            minimumWidth,
            Math.min(
                compactMaximumWidth,
                metrics.advanceWidth
                    + iconSlotWidth
                    + contentSpacing * 2
                    + Config.IslandConstants.notificationDismissSize
                    + horizontalPadding * 2
            )
        )
    readonly property real preferredWidth: expanded && hasOverflow
        ? expandedMaximumWidth : compactWidth
    readonly property real preferredHeight: expanded && hasOverflow
        ? Math.max(
            Config.IslandConstants.notificationExpandedMinimumHeight,
            Math.min(
                Config.IslandConstants.notificationExpandedMaximumHeight,
                expandedProbe.implicitHeight + expandedVerticalPadding * 2
            )
        )
        : (prefersWrap
            ? Config.IslandConstants.notificationWrappedHeight
            : Config.IslandConstants.notificationCompactHeight)

    Row {
        id: contentRow
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -(
            Config.IslandConstants.notificationDismissSize + root.contentSpacing
        ) / 2
        width: Math.min(
            parent.width - root.horizontalPadding * 2
                - Config.IslandConstants.notificationDismissSize
                - root.contentSpacing,
            root.iconSlotWidth + root.contentSpacing
                + (root.expanded ? root.expandedTextWidth
                    : Math.min(metrics.advanceWidth, root.compactTextWidth))
        )
        height: parent.height - (root.expanded
            ? root.expandedVerticalPadding * 2 : root.compactVerticalPadding * 2)
        spacing: root.contentSpacing

        Text {
            width: root.iconSlotWidth
            anchors.verticalCenter: parent.verticalCenter
            text: root.contentModel?.iconText ?? Config.IslandConstants.notificationIcon
            color: root.palette.surfaceForeground
            font.family: Config.IslandConstants.iconFontFamily
            font.pixelSize: Config.IslandConstants.iconFontSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Item {
            width: contentRow.width - root.iconSlotWidth - root.contentSpacing
            height: contentRow.height

            Text {
                visible: !(root.expanded && root.hasOverflow)
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                text: root.notificationText
                color: root.palette.surfaceForeground
                font.family: Config.IslandConstants.textFontFamily
                font.pixelSize: Config.IslandConstants.bodyFontSize
                font.weight: Font.DemiBold
                wrapMode: root.prefersWrap ? Text.WordWrap : Text.NoWrap
                maximumLineCount: root.prefersWrap ? 2 : 1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                lineHeight: 0.95
            }

            Flickable {
                visible: root.expanded && root.hasOverflow
                anchors.fill: parent
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                contentWidth: width
                contentHeight: expandedText.implicitHeight
                interactive: contentHeight > height

                Text {
                    id: expandedText
                    width: parent.width
                    text: root.notificationText
                    color: root.palette.surfaceForeground
                    font.family: Config.IslandConstants.textFontFamily
                    font.pixelSize: Config.IslandConstants.bodyFontSize
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 1.05
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.hasOverflow || Boolean(root.contentModel?.action)
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const action = root.contentModel?.action ?? ""
            if (action) {
                root.actionRequested(action)
                return
            }
            root.expandedRequested(!root.expanded)
        }
    }

    Rectangle {
        id: dismissButton
        z: 2
        anchors.right: parent.right
        anchors.rightMargin: Config.IslandConstants.notificationDismissMargin
        anchors.verticalCenter: parent.verticalCenter
        width: Config.IslandConstants.notificationDismissSize
        height: width
        radius: width / 2
        color: dismissMouse.containsMouse
            ? root.palette.surfaceContainerHighest
            : "transparent"

        Text {
            anchors.centerIn: parent
            text: Config.IslandConstants.closeIcon
            color: root.palette.surfaceVariantForeground
            font.family: Config.IslandConstants.iconFontFamily
            font.pixelSize: 12
        }

        MouseArea {
            id: dismissMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                mouse.accepted = true
                root.actionRequested("dismiss")
            }
        }
    }

    TextMetrics {
        id: metrics
        font.family: Config.IslandConstants.textFontFamily
        font.pixelSize: Config.IslandConstants.bodyFontSize
        font.weight: Font.DemiBold
        text: root.notificationText
    }

    Text {
        id: compactProbe
        x: -10000
        width: root.compactTextWidth
        opacity: 0
        text: root.notificationText
        font.family: Config.IslandConstants.textFontFamily
        font.pixelSize: Config.IslandConstants.bodyFontSize
        font.weight: Font.DemiBold
        wrapMode: Text.WordWrap
        lineHeight: 0.95
    }

    Text {
        id: expandedProbe
        x: -10000
        width: root.expandedTextWidth
        opacity: 0
        text: root.notificationText
        font.family: Config.IslandConstants.textFontFamily
        font.pixelSize: Config.IslandConstants.bodyFontSize
        font.weight: Font.DemiBold
        wrapMode: Text.WordWrap
        lineHeight: 1.05
    }
}
