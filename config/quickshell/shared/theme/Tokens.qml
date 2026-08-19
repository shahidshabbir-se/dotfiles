pragma Singleton

import QtQuick

// Non-palette chrome. Colors.qml stays matugen-generated.
QtObject {
    readonly property color whiteFaint: Qt.rgba(1, 1, 1, 0.032)
    readonly property color whiteSubtle: Qt.rgba(1, 1, 1, 0.045)
    readonly property color whiteSoft: Qt.rgba(1, 1, 1, 0.05)
    readonly property color whiteMuted: Qt.rgba(1, 1, 1, 0.055)
    readonly property color whiteHairline: Qt.rgba(1, 1, 1, 0.06)
    readonly property color whiteHover: Qt.rgba(1, 1, 1, 0.065)
    readonly property color whitePress: Qt.rgba(1, 1, 1, 0.075)
    readonly property color whiteStrong: Qt.rgba(1, 1, 1, 0.09)
    readonly property color whiteIntense: Qt.rgba(1, 1, 1, 0.12)

    readonly property color scrim: Qt.rgba(0, 0, 0, 0.62)

    function withAlpha(base, alpha) {
        return Qt.rgba(base.r, base.g, base.b, alpha)
    }
}
