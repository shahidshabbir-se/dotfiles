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
    
    readonly property color moduleBackground: withAlpha(mixColors(matugen.surfaceContainerLow, matugen.surfaceContainerHighest, 0.34), 0.82)
    readonly property color moduleBackgroundHover: withAlpha(matugen.primaryContainer, 0.22)
    readonly property color moduleBorder: withAlpha(matugen.outlineVariant, 0.72)
    readonly property color moduleBorderHover: withAlpha(matugen.primary, 0.48)
    
    readonly property color cpuIndicator: matugen.error
    readonly property color ramIndicator: matugen.secondary
    readonly property color indicatorBackground: withAlpha(matugen.surfaceVariant, 0.85)
    
    readonly property color timeText: matugen.tertiary
    readonly property color textPrimary: matugen.surfaceForeground
    readonly property color textSecondary: matugen.surfaceVariantForeground
    readonly property color visualizerColor: matugen.tertiary

    // Player colors
    readonly property color playerBorderHover: withAlpha(matugen.primary, 0.5)
    readonly property color playerGradientStart: withAlpha(matugen.surfaceContainerLow, 0.96)
    readonly property color playerGradientEnd: withAlpha(matugen.secondary, 0.55)
    
    // Volume colors
    readonly property color volumeBorderHover: withAlpha(matugen.primary, 0.5)
    readonly property color volumeBackgroundHover: withAlpha(matugen.primaryContainer, 0.2)
    readonly property color volumeBarBackground: withAlpha(matugen.surfaceVariant, 0.85)
    readonly property color volumeGradientStart: matugen.primary
    readonly property color volumeGradientEnd: matugen.tertiary
    
    // Weather colors
    readonly property color weatherBackground: moduleBackground
    readonly property color weatherBackgroundHover: withAlpha(matugen.secondaryContainer, 0.28)
    readonly property color weatherBorderHover: withAlpha(matugen.secondary, 0.5)
    readonly property color weatherTemperature: matugen.tertiary
    
    // Internet status colors
    readonly property color internetBackground: moduleBackground
    
    // System tray colors
    readonly property color trayBackgroundHover: withAlpha(matugen.surfaceVariantForeground, 0.1)
    readonly property color trayBorderHover: withAlpha(matugen.surfaceVariantForeground, 0.45)
    
    // Workspace colors
    readonly property color workspaceBackgroundHover: withAlpha(matugen.secondaryContainer, 0.28)
    readonly property color workspaceBorderHover: withAlpha(matugen.secondary, 0.45)
    readonly property color workspaceActive: matugen.primary
    readonly property color workspaceHover: withAlpha(matugen.surfaceContainerHighest, 1.0)
    readonly property color workspaceInactive: withAlpha(matugen.surfaceVariant, 0.85)

    // Power button colors
    readonly property color powerBackground: moduleBackground
    readonly property color powerBackgroundHover: withAlpha(matugen.errorContainer, 0.3)
    readonly property color powerBorder: moduleBorder
    readonly property color powerBorderHover: withAlpha(matugen.error, 0.55)
    
    // Battery colors
    readonly property color batteryBackground: withAlpha(mixColors(matugen.surfaceContainerLowest, matugen.surfaceContainer, 0.28), 0.82)
    readonly property color batteryHealthy: matugen.primary
    readonly property color batteryMedium: matugen.tertiary
    readonly property color batteryLow: matugen.error
    readonly property color batteryHealthyJuice: withAlpha(matugen.primary, 0.6)
    readonly property color batteryMediumJuice: withAlpha(matugen.tertiary, 0.6)
    readonly property color batteryLowJuice: withAlpha(matugen.error, 0.6)
    
    // Popout colors
    readonly property color popoutBackground: withAlpha(mixColors(matugen.surfaceContainerLow, matugen.surfaceContainerHighest, 0.32), 0.9)
    readonly property color popoutBorder: withAlpha(matugen.outline, 0.58)
    readonly property color backdropOverlay: withAlpha(matugen.shadow, 0.18)
}
