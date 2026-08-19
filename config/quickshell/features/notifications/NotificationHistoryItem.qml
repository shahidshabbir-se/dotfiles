pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Notifications
import qs.shared.theme
import "NotificationText.js" as NotificationText

Item {
    id: root

    required property var entry
    property double now: Date.now()
    property bool lastItem: false
    property real revealProgress: 0

    readonly property bool critical:
        entry.urgency === NotificationUrgency.Critical

    implicitHeight: Math.max(
        74,
        content.implicitHeight + NotificationMetrics.surfacePadding * 2
    )
    height: implicitHeight
    opacity: revealProgress
    scale: 0.98 + revealProgress * 0.02

    Component.onCompleted: Qt.callLater(() => revealProgress = 1)

    Behavior on revealProgress {
        NumberAnimation {
            duration: Constants.animationNormal
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: NotificationMetrics.historyRadius
        color: hoverHandler.hovered
            ? Tokens.whiteMuted
            : "transparent"

        Behavior on color {
            ColorAnimation { duration: Constants.animationFast }
        }
    }

    NotificationContent {
        id: content

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: Constants.paddingMd
            rightMargin: Constants.paddingMd
        }
        appName: root.entry.appName
        appIcon: root.entry.appIcon
        summary: root.entry.summary
        body: root.entry.body
        timeLabel: NotificationText.friendlyTime(root.entry.timestamp, root.now)
        critical: root.critical
        compact: true
    }

    Rectangle {
        visible: !root.lastItem
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: NotificationMetrics.historyIconSize
                + NotificationMetrics.contentGap
                + Constants.paddingMd
        }
        height: 1
        color: Tokens.whiteMuted
    }

    HoverHandler {
        id: hoverHandler
    }
}
