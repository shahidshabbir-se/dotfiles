pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import qs.shared.theme

// Screen-attached host for transient notifications. Live notification objects
// stay mounted while the stack changes between its compact and expanded forms.
PanelWindow {
    id: root

    required property var notificationModel
    property int defaultTimeoutMs: 6000
    property int maxVisible: 4
    property int topOffset: Constants.barTopMargin + Constants.barHeight + Constants.spacingMd
    property int rightOffset: Constants.spacingMd
    property bool suppressed: false
    property bool doNotDisturb: false
    property bool expanded: false
    property real retainedFrontHeight: 0

    readonly property int screenMargin: screen && screen.width < 448 ? 8 : 12
    readonly property int availableWidth: screen
        ? Math.max(1, screen.width - rightOffset - screenMargin)
        : NotificationMetrics.railWidth
    readonly property int cardWidth: Math.min(
        NotificationMetrics.railWidth,
        Math.max(1, availableWidth)
    )
    readonly property int windowWidth: cardWidth
    readonly property int usableHeight: screen
        ? Math.max(1, screen.height - topOffset - screenMargin)
        : NotificationMetrics.centerMaxHeight
    readonly property int notificationCount: displayModel.values.length
    readonly property bool hasNotifications: notificationCount > 0
    readonly property real currentFrontHeight: {
        const count = toastRepeater.count
        if (count === 0)
            return 0

        const front = toastRepeater.itemAt(0)
        return front ? front.surfaceHeight : 0
    }
    readonly property real collapsedHeight: retainedFrontHeight
        + Math.min(2, Math.max(0, notificationCount - 1))
            * NotificationMetrics.stackPeek
    readonly property real visibleStackHeight: expanded
        ? Math.min(stack.implicitHeight, usableHeight)
        : collapsedHeight

    function updateHoverState(hovered) {
        if (hovered) {
            collapseTimer.stop()
            expanded = notificationCount > 1
        } else if (expanded) {
            collapseTimer.restart()
        }
    }

    onCurrentFrontHeightChanged: {
        if (currentFrontHeight > 0)
            retainedFrontHeight = currentFrontHeight
    }

    onNotificationCountChanged: {
        if (notificationCount === 0)
            expanded = false
    }

    anchors {
        top: true
        right: true
    }

    margins {
        top: root.topOffset
        right: root.rightOffset
    }

    implicitWidth: windowWidth
    // Keep the Wayland surface stable while delegates are removed. Only the
    // input mask follows the visible footprint.
    implicitHeight: usableHeight
    visible: hasNotifications && !suppressed
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: false
    surfaceFormat.opaque: false

    WlrLayershell.namespace: "quickshell-notifications"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // In compact mode only the visible stack footprint is interactive. In
    // expanded mode the narrow gaps remain interactive intentionally, so the
    // stack cannot collapse while the pointer travels between cards.
    mask: Region {
        x: 0
        y: 0
        width: root.suppressed ? 0 : root.cardWidth
        height: root.suppressed
            ? 0
            : Math.ceil(Math.min(root.visibleStackHeight, root.usableHeight))
    }

    onSuppressedChanged: {
        if (suppressed) {
            collapseTimer.stop()
            expanded = false
        }
    }

    ScriptModel {
        id: displayModel

        values: root.notificationModel
            ? root.notificationModel.values
                .filter(notification => !root.doNotDisturb
                    || notification.urgency === NotificationUrgency.Critical)
                .slice()
                .reverse()
                .slice(0, Math.max(1, root.maxVisible))
            : []
    }

    Item {
        id: stackViewport

        anchors.fill: parent

        Item {
            id: collapsedPreviews

            x: 0
            width: root.cardWidth
            height: root.collapsedHeight
            z: 0

            // These shells are intentionally independent from notification
            // delegates. Model removal only fades a rounded shell; it cannot
            // expose a delegate or a resized rectangular viewport.
            Repeater {
                model: 2

                Rectangle {
                    required property int index

                    readonly property int depth: index + 1

                    x: depth * 9
                    y: depth * NotificationMetrics.stackPeek
                    width: Math.max(1, collapsedPreviews.width - depth * 18)
                    height: Math.max(1, root.retainedFrontHeight - depth * 2)
                    radius: Constants.panelRadius
                    color: depth === 1
                        ? Colors.surfaceContainer
                        : Colors.surfaceContainerLow
                    opacity: !root.expanded && root.notificationCount > depth
                        ? 1
                        : 0
                    z: -depth

                    Behavior on opacity {
                        NumberAnimation {
                            duration: NotificationMetrics.stackDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        Column {
            id: stack

            x: 0
            width: root.cardWidth
            spacing: NotificationMetrics.stackGap
            z: 1

            Repeater {
                id: toastRepeater

                model: displayModel

                NotificationToast {
                    required property var modelData
                    required property int index

                    width: stack.width
                    notification: modelData
                    defaultTimeoutMs: root.defaultTimeoutMs
                    stackIndex: index
                    stackExpanded: root.expanded
                    stackInteractive: root.expanded || index === 0
                    stackPositionY: root.expanded
                        ? y
                        : Math.min(index, 2) * NotificationMetrics.stackPeek
                    stackOpacity: root.expanded || index === 0 ? 1 : 0

                    onInteractionHoverChanged: hovered => root.updateHoverState(hovered)
                }
            }
        }

        HoverHandler {
            id: stackHover

            enabled: root.hasNotifications && !root.suppressed
            onHoveredChanged: root.updateHoverState(hovered)
        }
    }

    Timer {
        id: collapseTimer

        interval: 140
        repeat: false
        onTriggered: {
            if (!stackHover.hovered)
                root.expanded = false
        }
    }
}
