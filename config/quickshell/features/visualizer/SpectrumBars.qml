pragma ComponentBehavior: Bound

import QtQuick
import qs.shared.theme

Item {
    id: root

    required property var levels
    required property bool active
    property real maxBarHeight: height

    readonly property int barCount: Constants.visualizerBarCount
    readonly property real barSpacing: Constants.visualizerBarSpacing
    readonly property real barWidth: Constants.visualizerBarWidth
    readonly property real contentWidth:
        barCount * barWidth + (barCount - 1) * barSpacing
    readonly property real startX: Math.max(0, (width - contentWidth) / 2)

    function levelAt(index) {
        if (!levels || index < 0 || index >= levels.length)
            return 0

        const value = Number(levels[index])

        return isFinite(value) ? Math.min(1, Math.max(0, value)) : 0
    }

    Repeater {
        model: root.barCount

        Rectangle {
            id: bar

            required property int index

            readonly property real level: root.levelAt(index)
            readonly property real normalizedPosition:
                (index + 0.5) / root.barCount
            readonly property real centerWeight:
                Math.sin(Math.PI * normalizedPosition)
            readonly property real heightEnvelope:
                0.45 + 0.55 * Math.pow(centerWeight, 0.7)

            x: root.startX + index * (root.barWidth + root.barSpacing)
            anchors.bottom: parent.bottom
            width: root.barWidth
            height: root.active
                ? Math.max(
                    Constants.visualizerMinBarHeight,
                    Math.min(
                        root.maxBarHeight,
                        root.maxBarHeight
                            * Math.pow(level, 0.86)
                            * heightEnvelope
                    )
                )
                : 0
            radius: width / 2
            visible: height > 0
            opacity: 0.35 + 0.65 * Math.pow(centerWeight, 0.65)

            gradient: Gradient {
                orientation: Gradient.Vertical

                GradientStop { position: 0.00; color: "#e6fff8ef" }
                GradientStop { position: 0.28; color: "#d9b6c4ff" }
                GradientStop { position: 0.68; color: "#b3344479" }
                GradientStop { position: 1.00; color: "#66344479" }
            }
        }
    }
}
