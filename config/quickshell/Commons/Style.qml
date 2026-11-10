pragma Singleton

import QtQuick

QtObject {
    // Bar
    readonly property int barHeight: 36
    readonly property int barPadding: 12
    readonly property int barRadius: 0

    // Spacing
    readonly property int spacingXs: 4
    readonly property int spacingSm: 6
    readonly property int spacingMd: 8
    readonly property int spacingLg: 12
    readonly property int spacingXl: 16

    // Controls
    readonly property int widgetRadius: 4

    // Typography
    readonly property string fontFamily: "SF Pro Display"
    readonly property string monoFontFamily: "SpaceMono Nerd Font"
    readonly property int fontSizeSm: 12
    readonly property int fontSizeMd: 13
    readonly property int fontSizeLg: 16
}
