import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.shared.theme
import "NotificationText.js" as NotificationText

RowLayout {
    id: root

    required property string appName
    required property string summary
    property string appIcon: ""
    property string body: ""
    property string timeLabel: ""
    property bool critical: false
    property bool compact: false
    property int trailingReserve: 0

    readonly property string safeIconName: NotificationText.safeIconName(appIcon)
    readonly property bool isScreenshot: {
        const app = String(appName || "").toLowerCase()
        const sum = String(summary || "").toLowerCase()
        return app.includes("screenshot")
            || app.includes("grimblast")
            || sum.startsWith("screenshot")
    }
    readonly property bool isRecording: {
        const app = String(appName || "").toLowerCase()
        const sum = String(summary || "").toLowerCase()
        return app.includes("recording")
            || sum.startsWith("recording")
    }
    // absolute paths (notify-send image-path) bypass icon theme lookup
    readonly property string iconSource: (root.isScreenshot || root.isRecording)
        ? ""
        : (appIcon.startsWith("/") || appIcon.startsWith("file:")
            ? (appIcon.startsWith("file:") ? appIcon : ("file://" + appIcon))
            : (safeIconName ? Quickshell.iconPath(safeIconName, true) : ""))
    readonly property int iconExtent: compact
        ? NotificationMetrics.historyIconSize
        : NotificationMetrics.toastIconSize

    spacing: NotificationMetrics.contentGap

    Item {
        Layout.preferredWidth: root.iconExtent
        Layout.preferredHeight: root.iconExtent
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 1

        Rectangle {
            anchors.fill: parent
            visible: root.iconSource.length === 0
            radius: Constants.panelRadius
            color: Tokens.withAlpha(Colors.primary, 0.13)

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: parent.radius
                color: "transparent"
                border.width: 1
                border.color: Tokens.whiteHairline
            }

            ThemeIcon {
                anchors.centerIn: parent
                visible: root.isScreenshot || root.isRecording
                name: root.isRecording ? "video-camera" : "crop"
                iconSize: root.compact ? Constants.iconSizeMd : Constants.iconSizeLg
                iconColor: root.isRecording ? Colors.error : Colors.primary
            }

            Text {
                anchors.centerIn: parent
                visible: !root.isScreenshot && !root.isRecording
                text: root.appName.charAt(0).toUpperCase() || "?"
                color: Colors.primary
                font.family: Constants.fontFamily
                font.pixelSize: root.compact ? 15 : 17
                font.weight: Font.DemiBold
                textFormat: Text.PlainText
            }
        }

        Image {
            anchors.fill: parent
            anchors.margins: 2
            visible: root.iconSource.length > 0
            source: root.iconSource
            sourceSize.width: root.iconExtent * 2
            sourceSize.height: root.iconExtent * 2
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            mipmap: true
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.rightMargin: root.trailingReserve
        spacing: root.compact ? 3 : 4

        RowLayout {
            Layout.fillWidth: true
            spacing: Constants.spacingSm

            Text {
                Layout.fillWidth: true
                text: root.appName
                color: Colors.surfaceVariantForeground
                opacity: 0.76
                font.family: Constants.fontFamily
                font.pixelSize: Constants.fontSizeXs
                font.weight: Font.Medium
                font.letterSpacing: 0.15
                textFormat: Text.PlainText
                maximumLineCount: 1
                elide: Text.ElideRight
            }

            Rectangle {
                visible: root.critical
                Layout.preferredWidth: 6
                Layout.preferredHeight: 6
                radius: Constants.panelRadius
                color: Colors.error
            }

            Text {
                visible: root.timeLabel.length > 0
                text: root.timeLabel
                color: Colors.outline
                opacity: 0.8
                font.family: Constants.fontFamily
                font.pixelSize: Constants.fontSizeXs
                font.weight: Font.Medium
                textFormat: Text.PlainText
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.summary
            color: Colors.surfaceForeground
            font.family: Constants.fontFamily
            font.pixelSize: root.compact ? 14 : 15
            font.weight: Font.DemiBold
            font.letterSpacing: -0.1
            textFormat: Text.PlainText
            maximumLineCount: root.compact ? 2 : 2
            wrapMode: Text.Wrap
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            visible: root.body.length > 0
            text: root.body
            color: Colors.surfaceVariantForeground
            opacity: 0.86
            font.family: Constants.fontFamily
            font.pixelSize: 13
            font.weight: Font.Normal
            textFormat: Text.PlainText
            lineHeight: 1.14
            maximumLineCount: 1
            wrapMode: Text.Wrap
            elide: Text.ElideRight
        }
    }
}
