pragma Singleton
import QtQuick

QtObject {
    readonly property string textFontFamily: "Geist"
    readonly property string monoFontFamily: "Geist Mono"
    readonly property string iconFontFamily: "Symbols Nerd Font Mono"
    readonly property string timeFormat: "h:mm AP"
    readonly property string workspaceReserveText: "Workspace 10"

    readonly property int clockFontSize: 15
    readonly property int bodyFontSize: 16
    readonly property int iconFontSize: 18
    readonly property int clockHeight: 40
    readonly property int clockHorizontalPadding: 20
    readonly property int clockRefreshInterval: 1000

    readonly property int windowTopMargin: 8
    readonly property int windowSurfaceHeight: 348
    readonly property int windowExclusiveZone: 0
    readonly property int windowHorizontalInset: 24
    readonly property int edgeRevealHeight: 10
    readonly property int edgeRevealHideDelay: 300

    readonly property int capsuleMaximumWidth: 520
    readonly property int capsuleMorphDuration: 400
    readonly property int capsuleRevealDuration: 160
    readonly property int capsuleLargeRadius: 28
    readonly property int capsuleCompactHeightLimit: 68
    readonly property real capsuleBackgroundOpacity: 0.64

    readonly property int workspacePriority: 10
    readonly property int passivePriority: 20
    readonly property int interactivePriority: 30
    readonly property int workspaceTtl: 1200
    readonly property int popupTtl: 4200
    readonly property int mediaNotificationSuppressionInterval: 1500

    readonly property int notificationMinimumWidth: 272
    readonly property int notificationCompactMaximumWidth: 400
    readonly property int notificationExpandedMaximumWidth: 520
    readonly property int notificationExpandedMaximumHeight: 240
    readonly property int notificationCompactHeight: 56
    readonly property int notificationWrappedHeight: 68
    readonly property int notificationExpandedMinimumHeight: 84
    readonly property int notificationIconSlotWidth: 18
    readonly property int notificationContentSpacing: 13
    readonly property int notificationDismissSize: 24
    readonly property int notificationDismissMargin: 12
    readonly property int notificationHorizontalPadding: 16
    readonly property int notificationCompactVerticalPadding: 7
    readonly property int notificationExpandedVerticalPadding: 13

    readonly property int mediaWidth: 410
    readonly property int mediaHeight: 165
    readonly property int mediaPadding: 20
    readonly property int mediaArtSize: 60
    readonly property int mediaArtRadius: 14
    readonly property int mediaProgressHeight: 3
    readonly property int mediaProgressThumbSize: 10
    readonly property int mediaProgressPollInterval: 500
    readonly property int mediaSeekSettleInterval: 1000

    readonly property int launcherWidth: 520
    readonly property int launcherHeight: 306
    readonly property int launcherPadding: 16
    readonly property int launcherSearchHeight: 44
    readonly property int launcherResultHeight: 44
    readonly property int launcherVisibleResults: 5
    readonly property int launcherContentSpacing: 10
    readonly property int launcherIconSize: 30

    readonly property int clipboardWidth: 600
    readonly property int clipboardHeight: 348
    readonly property int clipboardPadding: 12
    readonly property int clipboardSearchHeight: 40
    readonly property int clipboardResultHeight: 46
    readonly property int clipboardVisibleResults: 6
    readonly property int clipboardContentSpacing: 8
    readonly property int clipboardIconSize: 17
    readonly property int clipboardThumbnailSize: 30
    readonly property int clipboardListWidth: 235
    readonly property int clipboardPaneSpacing: 8
    readonly property bool clipboardShowLinkVisuals: true
    readonly property int clipboardMaximumPreviewPixels: 33554432
    readonly property string clipboardFaviconService: "https://icons.duckduckgo.com/ip3/"

    readonly property string notificationIcon: "\uf0f3"
    readonly property string mediaIcon: "\uf001"
    readonly property string previousIcon: "\uf048"
    readonly property string playIcon: "\uf04b"
    readonly property string pauseIcon: "\uf04c"
    readonly property string nextIcon: "\uf051"
    readonly property string closeIcon: "\uf00d"
    readonly property string searchIcon: "\uf002"
    readonly property string imageIcon: "\uf03e"
}
