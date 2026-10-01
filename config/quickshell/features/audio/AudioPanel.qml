pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.shared.theme

// Audio panel content: hero switch, output section, input section, per-app
// streams. The keyboard cursor lives on the facade (see Audio.qml); this file
// only draws whatever the cursor currently points at.
Item {
    id: root

    required property var audio

    width: Constants.audioPopupWidth
    // Content-sized, capped at the panel maximum. Short panels (one sink, no
    // input) must not leave a tall empty shell behind.
    implicitHeight: Math.min(
        Constants.audioPopupMaxHeight,
        Math.max(shell.implicitHeight, 1)
    )

    Component.onCompleted: root.audio.scroller = flick
    Component.onDestruction: {
        if (root.audio.scroller === flick)
            root.audio.scroller = null
    }

    // Cursor band around a slider row: the only visual difference between
    // "keyboard is here" and "mouse is here" is this outline.
    component CursorBand: Rectangle {
        id: band

        property bool selected: false

        color: selected
            ? Tokens.withAlpha(Colors.primary, 0.12)
            : "transparent"
        radius: Constants.buttonRadius
        border.width: selected ? Constants.borderWidth : 0
        border.color: Tokens.withAlpha(Colors.primary, 0.5)

        Behavior on color {
            ColorAnimation { duration: Constants.animationFast }
        }
    }

    component SectionLabel: Text {
        color: Colors.outline
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeXs
        font.weight: Font.DemiBold
        font.letterSpacing: 0.9
        textFormat: Text.PlainText
    }

    component Percent: Text {
        color: Colors.surfaceVariantForeground
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeXs
        font.weight: Font.DemiBold
        textFormat: Text.PlainText
    }

    component Rule: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Constants.borderWidth
        color: Colors.surfaceContainerHighest
    }

    Rectangle {
        id: shell

        // Sized by its content; the panel caps the height at the maximum and
        // the Flickable takes over scrolling past that.
        width: parent.width
        implicitHeight: body.implicitHeight + Constants.paddingLg * 2
        radius: Constants.panelRadius
        color: Colors.surfaceContainerLow
        clip: true
        // The popup's own outline: primary, and tuned from Constants so the
        // weight and colour live in one place.
        border.width: Constants.popupBorderWidth
        border.color: Constants.popupBorderColor

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 6
            anchors.leftMargin: 2
            anchors.rightMargin: -2
            radius: parent.radius
            color: Tokens.withAlpha(Colors.shadow, 0.28)
            z: -1
        }

        Flickable {
            id: flick

            anchors.fill: parent
            anchors.leftMargin: Constants.paddingLg
            anchors.rightMargin: Constants.paddingLg
            anchors.topMargin: Constants.paddingLg
            anchors.bottomMargin: Constants.paddingLg
            clip: true
            contentWidth: width
            contentHeight: body.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            // Only take drags when there is something to scroll to. A Flickable
            // that could never move still competes for the grab, and a
            // horizontal slider drag is exactly the direction it watches for.
            interactive: body.implicitHeight > height + 1
            flickableDirection: Flickable.VerticalFlick

            ScrollBar.vertical: ScrollBar {
                policy: flick.contentHeight > flick.height
                    ? ScrollBar.AsNeeded
                    : ScrollBar.AlwaysOff
            }

            ColumnLayout {
                id: body

                width: flick.width
                spacing: Constants.spacingMd

                // ---------- Hero: status · master switch ----------
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Constants.spacingMd

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: root.audio.outputIcon()
                        textFormat: Text.PlainText
                        opacity: root.audio.outputMuted ? 0.5 : 1
                        color: Colors.surfaceForeground
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Constants.fontSizeXl + 4
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: "Audio"
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: Colors.surfaceForeground
                            font.family: Constants.fontFamily
                            font.pixelSize: Constants.fontSizeLg
                            font.weight: Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.audio.statusName().toUpperCase()
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: Colors.surfaceVariantForeground
                            font.family: Constants.fontFamily
                            font.pixelSize: Constants.fontSizeXs
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.1
                        }
                    }

                    // Checked means something is still audible, so the switch is
                    // the panel's on/off rather than "is the output muted".
                    ToggleSwitch {
                        Layout.alignment: Qt.AlignVCenter
                        interactive: root.audio.hasOutput || root.audio.hasInput
                        checked: root.audio.anyAudible
                        onToggled: root.audio.toggleAllMuted()
                    }
                }

                Rule {}

                // ---------- Output ----------
                SectionLabel {
                    text: "OUTPUT"
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: -Constants.spacingXs
                    spacing: Constants.spacingMd

                    CursorBand {
                        id: outputBand

                        Layout.fillWidth: true
                        Layout.preferredHeight: sliderRow.implicitHeight
                        Layout.bottomMargin: -Constants.spacingSm
                        selected: root.audio.cursorActive
                            && root.audio.focusSection === "output"
                            && root.audio.selectedIndex === -1

                        onSelectedChanged: {
                            if (selected)
                                root.audio.ensureCursorVisible(outputBand)
                        }

                        RowLayout {
                            id: sliderRow

                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: Constants.paddingSm
                            anchors.rightMargin: Constants.paddingSm
                            spacing: Constants.spacingMd

                            AudioSlider {
                                id: outputSlider

                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                value: root.audio.outputVolume
                                dimmed: root.audio.outputMuted
                                interactive: root.audio.hasOutput
                                onMoved: function(value) { root.audio.setOutputVolume(value) }
                                onToggleMute: root.audio.toggleOutputMute()
                            }

                            Percent {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredWidth: 34
                                horizontalAlignment: Text.AlignRight
                                opacity: root.audio.outputMuted ? 0.5 : 1
                                text: Math.round(outputSlider.shownValue * 100) + "%"
                            }
                        }
                    }
                }

                Repeater {
                    model: root.audio.displayAudioSinks

                    SinkRow {
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        audio: root.audio
                        node: modelData
                        rowIndex: index
                    }
                }

                // ---------- Input ----------
                Rule {
                    visible: root.audio.hasInputSection
                }

                SectionLabel {
                    visible: root.audio.hasInputSection
                    text: "INPUT"
                }

                RowLayout {
                    visible: root.audio.hasInputSection
                    Layout.fillWidth: true
                    Layout.topMargin: -Constants.spacingXs
                    spacing: Constants.spacingMd

                    CursorBand {
                        id: inputBand

                        Layout.fillWidth: true
                        Layout.preferredHeight: inputSliderRow.implicitHeight
                        Layout.bottomMargin: -Constants.spacingSm
                        selected: root.audio.cursorActive
                            && root.audio.focusSection === "input"
                            && root.audio.selectedIndex === -1

                        onSelectedChanged: {
                            if (selected)
                                root.audio.ensureCursorVisible(inputBand)
                        }

                        RowLayout {
                            id: inputSliderRow

                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: Constants.paddingSm
                            anchors.rightMargin: Constants.paddingSm
                            spacing: Constants.spacingMd

                            AudioSlider {
                                id: inputSlider

                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                value: root.audio.inputVolume
                                dimmed: root.audio.inputMuted
                                interactive: root.audio.hasInput
                                onMoved: function(value) { root.audio.setInputVolume(value) }
                                onToggleMute: root.audio.toggleInputMute()
                            }

                            Percent {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredWidth: 34
                                horizontalAlignment: Text.AlignRight
                                opacity: root.audio.inputMuted ? 0.5 : 1
                                text: Math.round(inputSlider.shownValue * 100) + "%"
                            }
                        }
                    }
                }

                Repeater {
                    model: root.audio.displayAudioSources

                    SourceRow {
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        audio: root.audio
                        node: modelData
                        rowIndex: index
                    }
                }

                // ---------- Per-app streams ----------
                Rule {
                    visible: root.audio.displayAudioStreams.length > 0
                }

                SectionLabel {
                    visible: root.audio.displayAudioStreams.length > 0
                    text: "SOURCES"
                }

                Repeater {
                    model: root.audio.displayAudioStreams

                    StreamRow {
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        audio: root.audio
                        node: modelData
                        rowIndex: index
                    }
                }
            }
        }
    }
}
