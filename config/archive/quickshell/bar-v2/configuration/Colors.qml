pragma Singleton
import QtQuick

QtObject {
    readonly property QtObject matugen: MatugenColors {}

    function withAlpha(colorValue, alphaValue) {
        return Qt.rgba(colorValue.r, colorValue.g, colorValue.b, alphaValue)
    }

    function mixColors(colorA, colorB, ratio) {
        const inverse = 1 - ratio
        return Qt.rgba(
            colorA.r * inverse + colorB.r * ratio,
            colorA.g * inverse + colorB.g * ratio,
            colorA.b * inverse + colorB.b * ratio,
            colorA.a * inverse + colorB.a * ratio
        )
    }

    readonly property color barBackground: withAlpha(mixColors(matugen.surfaceContainerLowest, matugen.surfaceContainerHigh, 0.42), 0.74)
    readonly property color barBorder: withAlpha(matugen.outline, 0.52)

    readonly property color textPrimary: matugen.surfaceForeground
    readonly property color textSecondary: matugen.surfaceVariantForeground
    readonly property color textMuted: withAlpha(matugen.outline, 0.85)

    readonly property color workspaceActiveBg: withAlpha(matugen.primaryContainer, 0.95)
    readonly property color workspaceActiveText: matugen.primaryContainerForeground
    readonly property color workspaceInactiveText: withAlpha(matugen.surfaceVariantForeground, 0.72)

    readonly property color moduleBackground: withAlpha(mixColors(matugen.surfaceContainerLow, matugen.surfaceContainerHighest, 0.34), 0.82)
    readonly property color moduleBackgroundHover: withAlpha(matugen.primaryContainer, 0.22)
    readonly property color moduleBorder: withAlpha(matugen.outlineVariant, 0.72)
    readonly property color moduleBorderHover: withAlpha(matugen.primary, 0.48)
    readonly property color workspaceBackgroundHover: withAlpha(matugen.secondaryContainer, 0.28)
    readonly property color workspaceBorderHover: withAlpha(matugen.secondary, 0.45)
    readonly property color workspaceActive: matugen.primary
    readonly property color workspaceHover: withAlpha(matugen.surfaceContainerHighest, 1.0)
    readonly property color workspaceInactive: withAlpha(matugen.surfaceVariant, 0.85)

    readonly property color separator: withAlpha(matugen.outlineVariant, 0.55)

    readonly property color batteryHealthy: matugen.primary
    readonly property color batteryMedium: matugen.tertiary
    readonly property color batteryLow: matugen.error
    readonly property color batteryBackground: withAlpha(matugen.surfaceVariant, 0.85)

    readonly property color controlHover: withAlpha(matugen.primaryContainer, 0.35)
    readonly property color volumeBarBackground: withAlpha(matugen.surfaceVariant, 0.85)
    readonly property color volumeGradientStart: matugen.primary
    readonly property color volumeGradientEnd: matugen.tertiary
    readonly property color volumeBoost: matugen.error
    readonly property color volumeBorderHover: withAlpha(matugen.primary, 0.5)
    readonly property color volumeBackgroundHover: withAlpha(matugen.primaryContainer, 0.2)
    readonly property color popoutBackground: withAlpha(mixColors(matugen.surfaceContainerLow, matugen.surfaceContainerHighest, 0.32), 0.9)
    readonly property color popoutBorder: withAlpha(matugen.outline, 0.45)

    readonly property color playerPanelBackground: withAlpha(matugen.surfaceContainerHigh, 0.78)
    readonly property color playerPanelBorder: withAlpha(matugen.outline, 0.45)
    readonly property color playerAccent: matugen.primary
    readonly property color playerAccentForeground: matugen.primaryForeground
    readonly property color playerControlBg: withAlpha(matugen.surfaceContainerHighest, 0.9)
    readonly property color playerProgressBg: withAlpha(matugen.surfaceVariant, 0.9)
    readonly property color playerSpotify: "#1db954"

    readonly property color notificationPanelBackground: withAlpha(mixColors(matugen.surfaceContainerHigh, matugen.surfaceContainer, 0.38), 0.88)
    readonly property color notificationPanelBorder: withAlpha(matugen.outline, 0.32)
    readonly property color notificationCardBackground: withAlpha(matugen.surfaceContainerHighest, 0.45)
    readonly property color notificationCardHover: withAlpha(matugen.primaryContainer, 0.18)
    readonly property color notificationIconBackground: withAlpha(matugen.primaryContainer, 0.28)
    readonly property color notificationAccent: matugen.primary
    readonly property color notificationUnreadDot: matugen.primary
    readonly property color notificationBadgeBg: withAlpha(matugen.primaryContainer, 0.95)
    readonly property color notificationBadgeText: matugen.primaryContainerForeground
    readonly property color notificationDndTrack: withAlpha(matugen.surfaceVariant, 0.9)
    readonly property color notificationDndOn: withAlpha(matugen.primaryContainer, 0.95)
    readonly property color notificationDndThumb: matugen.primaryContainerForeground
    readonly property color notificationClearBorder: withAlpha(matugen.outline, 0.45)

    readonly property color powerBackground: moduleBackground
    readonly property color powerBackgroundHover: withAlpha(matugen.errorContainer, 0.3)
    readonly property color powerBorder: moduleBorder
    readonly property color powerBorderHover: withAlpha(matugen.error, 0.55)
    readonly property color powerIcon: textSecondary
    readonly property color powerIconHover: matugen.error
}
