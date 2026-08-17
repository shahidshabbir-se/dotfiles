pragma Singleton

import QtQuick
import qs.shared.theme

QtObject {
    readonly property int railWidth: 408
    readonly property int windowGutter: 12
    readonly property int centerMaxHeight: 680

    readonly property int surfaceRadius: 22
    readonly property int historyRadius: 16
    readonly property int controlRadius: 10

    readonly property int toastIconSize: 44
    readonly property int historyIconSize: 40
    readonly property int surfacePadding: 16
    readonly property int contentGap: 14
    readonly property int stackGap: 14
    readonly property int stackPeek: 10

    readonly property int actionHeight: 34
    readonly property int actionRevealDuration: Constants.animationNormal
    readonly property int enterDuration: 230
    readonly property int exitDuration: 150
    readonly property int stackDuration: 240
    readonly property int centerEnterDuration: 220
    readonly property int centerExitDuration: 140
}
