pragma Singleton

import QtQuick
import qs.shared.theme

QtObject {
    readonly property int railWidth: 408
    readonly property int windowGutter: 12
    readonly property int centerMaxHeight: 680

    readonly property int surfaceRadius: Constants.panelRadius
    readonly property int historyRadius: Constants.panelRadius
    readonly property int controlRadius: Constants.panelRadius

    readonly property int toastIconSize: 44
    readonly property int historyIconSize: 40
    readonly property int surfacePadding: 16
    readonly property int contentGap: 14
    readonly property int stackGap: 14
    readonly property int stackPeek: 10

    readonly property int actionHeight: 34
    readonly property int actionRevealDuration: Constants.animationNormal
    readonly property int enterDuration: Constants.popupEnterMs
    readonly property int exitDuration: Constants.popupExitMs
    readonly property int stackDuration: Constants.animationSlow
    readonly property int centerEnterDuration: Constants.popupEnterMs
    readonly property int centerExitDuration: Constants.popupExitMs
}
