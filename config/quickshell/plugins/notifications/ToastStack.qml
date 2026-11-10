pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../Commons"
import "Format.js" as Format

PanelWindow {
    id: root

    required property var notificationModel
    property int maxVisible: 4
    property int defaultTimeoutMs: 6000

    readonly property var toastValues: root.notificationModel
        ? Format.visibleToasts(root.notificationModel.values, root.maxVisible)
        : []
    readonly property int toastCount: toastValues.length
    readonly property int panelWidth: screen
        ? Math.min(380, Math.max(1, screen.width - Style.spacingMd * 2))
        : 380

    anchors {
        top: true
        right: true
    }

    margins {
        top: Style.barHeight + Style.spacingMd
        right: Style.spacingMd
    }

    implicitWidth: panelWidth
    implicitHeight: stack.implicitHeight
    visible: toastCount > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: false
    surfaceFormat.opaque: false

    WlrLayershell.namespace: "qs-toasts"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    ScriptModel {
        id: toastModel

        values: root.toastValues
    }

    Column {
        id: stack

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        spacing: Style.spacingSm

        Repeater {
            id: toastRepeater

            model: toastModel

            Toast {
                required property var modelData

                width: stack.width
                notification: modelData
                defaultTimeoutMs: root.defaultTimeoutMs
            }
        }
    }
}
