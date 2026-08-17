pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import qs.shared.theme
import "NotificationText.js" as NotificationText

Item {
    id: root

    signal interactionHoverChanged(bool active)

    required property var notification
    property int defaultTimeoutMs: 6000

    property int stackIndex: 0
    property bool stackExpanded: true
    property bool stackInteractive: true
    property real stackPositionY: 0
    property real stackOpacity: 1

    property bool exiting: false
    property bool expireOnExit: false
    property bool dragDismiss: false
    property real visualOpacity: 0
    property real horizontalOffset: 18
    property real verticalOffset: -14
    property real visualScale: 0.955
    property real actionProgress: hovered && hasActions ? 1 : 0
    property real dragOffsetX: 0

    readonly property bool critical:
        notification.urgency === NotificationUrgency.Critical
    readonly property bool hovered: hoverHandler.hovered
    readonly property var visibleActions: notification.actions.filter(
        action => action.identifier !== "default"
    )
    readonly property var defaultAction: {
        for (let i = 0; i < notification.actions.length; i++) {
            const action = notification.actions[i]

            if (action.identifier === "default")
                return action
        }

        return null
    }
    readonly property bool hasActions: visibleActions.length > 0
    readonly property string cleanAppName:
        NotificationText.singleLine(notification.appName, 128) || "Notification"
    readonly property string cleanSummary:
        NotificationText.singleLine(notification.summary, 512) || "Notification"
    readonly property string cleanNotificationBody:
        NotificationText.body(notification.body)
    readonly property int effectiveTimeoutMs: {
        if (critical || notification.expireTimeout === 0)
            return 0

        if (notification.expireTimeout > 0)
            return Math.min(30000, Math.max(1000, notification.expireTimeout))

        return defaultTimeoutMs
    }
    readonly property real surfaceHeight:
        contentLayout.implicitHeight + NotificationMetrics.surfacePadding * 2

    implicitHeight: Math.ceil(surfaceHeight)
    height: implicitHeight
    z: 100 - stackIndex

    onHoveredChanged: {
        interactionHoverChanged(hovered)
    }

    function finishExit() {
        if (expireOnExit)
            notification.expire()
        else
            notification.dismiss()
    }

    // Collapsed rear cards are represented by stable preview shells. Their
    // live delegates can leave immediately without exposing transformed clips.
    function closeAfterAnimation(expired, dragged) {
        if (exiting)
            return

        expireOnExit = expired
        dragDismiss = dragged === true
        exiting = true
        entranceAnimation.stop()

        if (!stackExpanded && stackIndex > 0 && !dragDismiss) {
            finishExit()
            return
        }

        exitAnimation.start()
    }

    Component.onCompleted: entranceDelay.start()

    HoverHandler {
        id: hoverHandler

        enabled: root.stackInteractive && !root.exiting
    }

    DragHandler {
        id: swipeHandler

        target: null
        enabled: root.stackInteractive && !root.exiting
        acceptedButtons: Qt.LeftButton
        xAxis.enabled: true
        yAxis.enabled: false
        cursorShape: active ? Qt.ClosedHandCursor : Qt.ArrowCursor

        onActiveTranslationChanged: {
            root.dragOffsetX = Math.max(0, activeTranslation.x)
        }

        onActiveChanged: {
            if (active)
                return

            if (root.dragOffsetX >= root.width * 0.22)
                root.closeAfterAnimation(false, true)
            else
                root.dragOffsetX = 0
        }
    }

    TapHandler {
        enabled: root.stackInteractive && !root.exiting
        acceptedButtons: Qt.RightButton
        onTapped: root.closeAfterAnimation(false, false)
    }

    Item {
        id: stackLayer

        anchors.fill: parent
        opacity: root.stackOpacity

        transform: Translate {
            // Column geometry may change instantly. Subtracting the layout y
            // leaves stackPositionY as the single animated visual coordinate.
            y: root.stackPositionY - root.y
        }

        Behavior on opacity {
            NumberAnimation {
                duration: NotificationMetrics.stackDuration
                easing.type: Easing.OutCubic
            }
        }

        Item {
            id: arrivalLayer

            anchors.fill: parent
            opacity: root.visualOpacity * (1 - Math.min(
                0.32,
                root.dragOffsetX / Math.max(1, root.width) * 0.45
            ))
            scale: root.visualScale * (1 - Math.min(
                0.018,
                root.dragOffsetX / Math.max(1, root.width) * 0.025
            ))
            transformOrigin: Item.TopRight

            transform: Translate {
                x: root.horizontalOffset + root.dragOffsetX
                y: root.verticalOffset
            }

            Rectangle {
                id: surface

                width: parent.width
                height: root.surfaceHeight
                radius: NotificationMetrics.surfaceRadius
                color: root.hovered
                    ? Colors.surfaceContainer
                    : Colors.surfaceContainerLow

                Behavior on color {
                    ColorAnimation { duration: Constants.animationFast }
                }

                Rectangle {
                    anchors.fill: parent
                    visible: root.critical
                    radius: parent.radius
                    color: Qt.rgba(Colors.error.r, Colors.error.g, Colors.error.b, 0.035)
                }

                ColumnLayout {
                    id: contentLayout

                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: NotificationMetrics.surfacePadding
                        rightMargin: NotificationMetrics.surfacePadding
                    }
                    spacing: 0
                    opacity: root.stackExpanded || root.stackIndex === 0 ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Constants.animationFast
                            easing.type: Easing.OutCubic
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: notificationContent.implicitHeight

                        NotificationContent {
                            id: notificationContent

                            anchors.fill: parent
                            appName: root.cleanAppName
                            appIcon: root.notification.appIcon
                            summary: root.cleanSummary
                            body: root.cleanNotificationBody
                            timeLabel: "now"
                            critical: root.critical
                            trailingReserve: 34
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: root.defaultAction !== null
                                && root.stackInteractive
                                && !root.exiting
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: root.defaultAction.invoke()
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.actionProgress
                            * (NotificationMetrics.actionHeight + Constants.spacingXl)
                        opacity: root.actionProgress
                        clip: true

                        Rectangle {
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                topMargin: Constants.spacingMd
                            }
                            height: 1
                            color: Qt.rgba(1, 1, 1, 0.06)
                        }

                        NotificationActions {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }
                            enabled: root.actionProgress > 0.9
                            actions: root.visibleActions
                        }
                    }
                }

                Rectangle {
                    anchors {
                        top: parent.top
                        right: parent.right
                        margins: 10
                    }
                    width: 27
                    height: 27
                    radius: 13.5
                    opacity: root.hovered
                        && (root.stackExpanded || root.stackIndex === 0)
                        ? 1
                        : 0
                    enabled: opacity > 0.8
                    color: closeArea.containsMouse
                        ? Qt.rgba(1, 1, 1, 0.12)
                        : Qt.rgba(1, 1, 1, 0.065)
                    scale: closeArea.pressed ? 0.92 : 1

                    Behavior on opacity {
                        NumberAnimation { duration: Constants.animationFast }
                    }

                    Behavior on color {
                        ColorAnimation { duration: Constants.animationFast }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: Constants.animationFast
                            easing.type: Easing.OutCubic
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -1
                        text: "×"
                        color: Colors.surfaceVariantForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: 17
                        font.weight: Font.Medium
                        textFormat: Text.PlainText
                    }

                    MouseArea {
                        id: closeArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closeAfterAnimation(false)
                    }
                }
            }
        }
    }

    Behavior on actionProgress {
        NumberAnimation {
            duration: NotificationMetrics.actionRevealDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on stackPositionY {
        NumberAnimation {
            duration: NotificationMetrics.stackDuration
            easing.type: Easing.InOutCubic
        }
    }

    Behavior on dragOffsetX {
        enabled: !swipeHandler.active && !root.exiting

        NumberAnimation {
            duration: Constants.animationNormal
            easing.type: Easing.OutCubic
        }
    }

    Timer {
        id: entranceDelay

        interval: Math.min(root.stackIndex, 2) * 20
        repeat: false
        onTriggered: entranceAnimation.start()
    }

    ParallelAnimation {
        id: entranceAnimation

        NumberAnimation {
            target: root
            property: "visualOpacity"
            from: 0
            to: 1
            duration: 170
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root
            property: "horizontalOffset"
            from: 18
            to: 0
            duration: NotificationMetrics.enterDuration
            easing.type: Easing.OutExpo
        }

        NumberAnimation {
            target: root
            property: "verticalOffset"
            from: -14
            to: 0
            duration: NotificationMetrics.enterDuration
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root
            property: "visualScale"
            from: 0.955
            to: 1
            duration: NotificationMetrics.enterDuration
            easing.type: Easing.OutBack
            easing.overshoot: 0.16
        }
    }

    ParallelAnimation {
        id: exitAnimation

        NumberAnimation {
            target: root
            property: "visualOpacity"
            to: 0
            duration: 120
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root
            property: "dragOffsetX"
            to: root.dragDismiss ? root.width * 0.45 : 0
            duration: NotificationMetrics.exitDuration
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root
            property: "horizontalOffset"
            to: 16
            duration: NotificationMetrics.exitDuration
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root
            property: "verticalOffset"
            to: -10
            duration: NotificationMetrics.exitDuration
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root
            property: "visualScale"
            to: 0.97
            duration: NotificationMetrics.exitDuration
            easing.type: Easing.OutCubic
        }

        onFinished: root.finishExit()
    }

    Timer {
        interval: Math.max(1, root.effectiveTimeoutMs)
        running: root.effectiveTimeoutMs > 0
            && !root.hovered
            && !swipeHandler.active
            && !root.exiting
        repeat: false
        onTriggered: root.closeAfterAnimation(true)
    }
}
