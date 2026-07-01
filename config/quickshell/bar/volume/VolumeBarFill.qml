import QtQuick
import qs.configuration

Item {
    id: root

    property real volume: 0
    property bool muted: false
    property bool vertical: false
    property int cornerRadius: 2

    readonly property real level: muted ? 0 : Math.max(0, volume)
    readonly property real trackSize: vertical ? height : width
    readonly property bool hasBoost: boostSize > 0

    readonly property real normalSize: {
        if (level <= 0)
            return 0
        if (level <= 1)
            return trackSize * level
        return trackSize * (1 / level)
    }

    readonly property real boostSize: level <= 1 ? 0 : trackSize * ((level - 1) / level)

    readonly property int normalEndRadius: hasBoost || level < 1 ? 0 : cornerRadius

    Rectangle {
        id: normalFillH
        visible: !root.vertical && root.normalSize > 0
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.normalSize

        topLeftRadius: root.cornerRadius
        bottomLeftRadius: root.cornerRadius
        topRightRadius: root.normalEndRadius
        bottomRightRadius: root.normalEndRadius

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: Colors.volumeGradientStart }
            GradientStop { position: 1; color: Colors.volumeGradientEnd }
        }

        Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    }

    Rectangle {
        visible: !root.vertical && root.boostSize > 0
        color: Colors.volumeBoost
        anchors.left: normalFillH.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.boostSize

        topLeftRadius: 0
        bottomLeftRadius: 0
        topRightRadius: root.cornerRadius
        bottomRightRadius: root.cornerRadius

        Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    }

    Rectangle {
        id: normalFillV
        visible: root.vertical && root.normalSize > 0
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: root.normalSize

        bottomLeftRadius: root.cornerRadius
        bottomRightRadius: root.cornerRadius
        topLeftRadius: root.normalEndRadius
        topRightRadius: root.normalEndRadius

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0; color: Colors.volumeGradientStart }
            GradientStop { position: 1; color: Colors.volumeGradientEnd }
        }

        Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        visible: root.vertical && root.boostSize > 0
        color: Colors.volumeBoost
        anchors.bottom: normalFillV.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: root.boostSize

        topLeftRadius: root.cornerRadius
        topRightRadius: root.cornerRadius
        bottomLeftRadius: 0
        bottomRightRadius: 0

        Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }
}
