pragma Singleton

import QtQuick

QtObject {
    // Bar
    readonly property int barHeight: 32
    readonly property int barVerticalWidth: 32
    readonly property int barTopMargin: 0
    readonly property int panelRadius: 0
    readonly property real barWidthRatio: 1
    readonly property real barHeightRatio: 0.85
    readonly property int barMaxWidth: 9999
    readonly property int workspaceRefreshInterval: 500
    readonly property int workspaceRefreshAttempts: 6

    // Calendar
    readonly property int calendarWidth: 320
    readonly property int calendarMainHeight: 336
    readonly property int calendarHeaderHeight: barHeight
    readonly property int calendarNavigationSize: buttonSize
    readonly property int calendarWeekdayHeight: buttonSize
    readonly property int calendarDaySize: buttonSize
    readonly property int calendarColumns: 7
    readonly property int calendarCellCount: 42
    readonly property int calendarMonthSlideDistance: spacingXl
    readonly property int borderWidth: 1

    // Music
    readonly property int musicPopupWidth: 300
    readonly property int musicPopupHeight: 500
    readonly property int musicArtworkSize: 255
    readonly property int musicControlSize: 36
    readonly property int musicPrimaryControlSize: 40

    // Network
    readonly property int networkPopupWidth: 520
    readonly property int networkPopupMaxHeight: 680
    readonly property int networkRowHeight: 44
    readonly property int networkSignalBars: 4

    // Bluetooth
    readonly property int bluetoothPopupWidth: 380
    readonly property int bluetoothPopupMaxHeight: 560

    // Launcher
    readonly property int launcherWidth: 520
    readonly property int launcherMaxHeight: 560
    readonly property int launcherRowHeight: 44
    readonly property int launcherIconSize: 28

    // Audio visualizer
    readonly property int visualizerHeight: 72
    readonly property real visualizerWidthRatio: 0.60
    readonly property int visualizerMaxWidth: 640
    readonly property int visualizerBottomMargin: 10
    readonly property int visualizerBarCount: 71
    readonly property int visualizerBarWidth: 5
    readonly property int visualizerBarSpacing: 4
    readonly property int visualizerMinBarHeight: 3
    readonly property int visualizerMaxBarHeight: 54

    // Spacing
    readonly property int spacingXs: 4
    readonly property int spacingSm: 6
    readonly property int spacingMd: 8
    readonly property int spacingLg: 12
    readonly property int spacingXl: 16

    // Padding
    readonly property int paddingSm: 6
    readonly property int paddingMd: 8
    readonly property int paddingLg: 14

    // Controls
    readonly property int buttonSize: 28
    readonly property int buttonRadius: panelRadius

    // Typography
    readonly property string fontFamily: "Space Grotesk"
    readonly property int fontSizeXs: 11
    readonly property int fontSizeSm: 12
    readonly property int fontSizeMd: 14
    readonly property int fontSizeLg: 16
    readonly property int fontSizeXl: 20

    // Icons
    readonly property int iconSizeMd: 14
    readonly property int iconSizeLg: 16

    // Animation — Fluent-ish control motion (Win11 flyout feel)
    readonly property int animationFast: 120
    readonly property int animationNormal: 167
    readonly property int animationSlow: 250
    readonly property int popupEnterMs: 167
    readonly property int popupExitMs: 100
    readonly property real popupFromScale: 0.95
}
