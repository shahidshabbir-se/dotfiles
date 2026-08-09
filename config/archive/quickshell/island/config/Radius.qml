pragma Singleton
import QtQuick

QtObject {
    readonly property int none: 0
    readonly property int xs: 2
    readonly property int sm: 4
    readonly property int md: 8
    readonly property int lg: 12
    readonly property int xl: 16
    readonly property int full: 9999

    function capsule(height) {
        return height / 2
    }

    function circle(size) {
        return size / 2
    }
}
