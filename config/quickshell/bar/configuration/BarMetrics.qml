pragma Singleton
import QtQuick

QtObject {
    readonly property int barTopMargin: 8
    readonly property int barBottomMargin: 8
    readonly property int barVisualHeight: 38
    readonly property int panelHeight: barTopMargin + barVisualHeight
    readonly property real barWidthRatio: 0.75
    readonly property int popupGap: 8
    readonly property int popupTopMargin: panelHeight + popupGap
    readonly property int toastRightMargin: 8
    readonly property int notificationToastHideMs: 5000
    readonly property int screenshotOverlayHideMs: notificationToastHideMs / 2

    readonly property int notificationPanelWidth: 360
    readonly property int notificationPanelHeight: 459
    readonly property int notificationPanelExpandedHeight: 509
    readonly property int notificationPanelMaxHeight: 560
    readonly property int notificationPanelMargins: 32
    readonly property int notificationPanelHeaderHeight: 58
    readonly property int notificationPanelFooterHeight: 36
    readonly property int notificationListHeight: notificationPanelHeight
        - notificationPanelMargins
        - notificationPanelHeaderHeight
        - 29

    function popupRightMargin(screen) {
        if (!screen)
            return 28
        return Math.max(28, Math.round(screen.width * (1 - barWidthRatio) / 2))
    }

    function popupLeftMargin(screen) {
        if (!screen)
            return 0
        return Math.round(screen.width * (1 - barWidthRatio) / 2)
    }
}
