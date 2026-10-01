pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.shared.theme

// Weather panel: hero (condition glyph, temperature, location, stats) and a
// three-day forecast row. The location label is a tap target that swaps for a
// search field with geocoded suggestions.
Item {
    id: root

    // From the module singleton, because the bar hosts this panel: Quickshell
    // anchors a popup to an item, so the panel has to live in the bar's window
    // to sit under the clock.
    readonly property var weather: WeatherRuntime.facade
    property bool open: false

    width: Constants.weatherPopupWidth
    implicitHeight: Math.min(
        Constants.weatherPopupMaxHeight,
        Math.max(shell.implicitHeight, 1)
    )

    // Hairline between sections. The margins are what create the rhythm: the
    // body spacing is small, and the rule carries the visual break with equal
    // air on both sides of it.
    component Rule: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Constants.borderWidth
        Layout.topMargin: Constants.spacingMd
        Layout.bottomMargin: Constants.spacingMd
        color: Colors.surfaceContainerHighest
    }

    component SectionLabel: Text {
        color: Colors.outline
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeXs
        font.weight: Font.DemiBold
        font.letterSpacing: 1.1
        textFormat: Text.PlainText
    }

    // Same entrance as the network, music and bluetooth popups: a short reveal
    // and scale from the panel's corner, not a hard appear.
    QtObject {
        id: entrance

        property real revealProgress: 0

        function play() {
            reset()
            Qt.callLater(() => {
                if (root.open)
                    revealProgress = 1
            })
        }

        function reset() {
            revealProgress = 0
        }
    }

    onOpenChanged: {
        if (open)
            entrance.play()
        else
            entrance.reset()
    }

    Component.onCompleted: {
        if (open)
            entrance.play()
    }

    opacity: entrance.revealProgress
    scale: Constants.popupFromScale
        + entrance.revealProgress * (1 - Constants.popupFromScale)

    Behavior on opacity {
        NumberAnimation {
            duration: root.open ? Constants.popupEnterMs : Constants.popupExitMs
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.open ? Constants.popupEnterMs : Constants.popupExitMs
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: shell

        // Sized by its content; the panel caps the height and the Flickable
        // takes over scrolling past that.
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
            id: scroll

            anchors.fill: parent
            anchors.leftMargin: Constants.paddingLg
            anchors.rightMargin: Constants.paddingLg
            anchors.topMargin: Constants.paddingLg + (1 - entrance.revealProgress) * 8
            anchors.bottomMargin: Constants.paddingLg
            clip: true
            contentWidth: width
            contentHeight: body.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            // Only take drags when there is something to scroll to, so a
            // Flickable that could never move does not compete for the grab.
            interactive: body.implicitHeight > height + 1
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout {
                id: body

                width: scroll.width
                spacing: Constants.spacingLg

                // ---------- Hero: condition · temperature · stats ----------
                Item {
                    Layout.fillWidth: true
                    implicitHeight: Math.max(heroLeft.implicitHeight, heroRight.implicitHeight)

                    ColumnLayout {
                        id: heroLeft

                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Constants.spacingXs

                        RowLayout {
                            spacing: Constants.spacingLg

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                textFormat: Text.PlainText
                                text: root.weather.label.length > 0 ? root.weather.label : "—"
                                color: Colors.surfaceForeground
                                font.family: "JetBrainsMono Nerd Font"
                                // Decorative condition glyph, deliberately larger
                                // than the font scale.
                                font.pixelSize: 56
                            }

                            RowLayout {
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2

                                Text {
                                    textFormat: Text.PlainText
                                    text: root.weather.reportTempNum.length > 0 ? root.weather.reportTempNum : "—"
                                    color: Colors.surfaceForeground
                                    font.family: Constants.fontFamily
                                    font.pixelSize: 44
                                    font.weight: Font.Bold
                                }

                                Text {
                                    Layout.alignment: Qt.AlignTop
                                    Layout.topMargin: 8
                                    textFormat: Text.PlainText
                                    text: root.weather.current ? root.weather.tempUnit : ""
                                    color: Colors.surfaceForeground
                                    font.family: Constants.fontFamily
                                    font.pixelSize: Constants.fontSizeLg
                                }
                            }
                        }

                        // Day range and chance of rain sit under the hero
                        // starting from the cloud icon.
                        Text {
                            visible: !!root.weather.todayForecast
                            textFormat: Text.PlainText
                            text: (root.weather.todayForecast
                                    ? WeatherLabels.bareTempForDay(root.weather.todayForecast, "max", root.weather.useImperial)
                                        + " / "
                                        + WeatherLabels.bareTempForDay(root.weather.todayForecast, "min", root.weather.useImperial)
                                        + (WeatherLabels.forecastPrecipitation(root.weather.todayForecast) !== ""
                                            ? "  ·  " + WeatherLabels.forecastPrecipitation(root.weather.todayForecast)
                                            : "")
                                    : "")
                            color: Colors.surfaceVariantForeground
                            font.family: Constants.fontFamily
                            font.pixelSize: Constants.fontSizeSm
                        }
                    }

                    ColumnLayout {
                        id: heroRight

                        Layout.alignment: Qt.AlignVCenter
                        anchors.right: parent.right
                        spacing: Constants.spacingMd

                        RowLayout {
                            visible: !root.weather.editingLocation && root.weather.reportLocation !== ""
                            spacing: Constants.spacingSm

                            Text {
                                textFormat: Text.PlainText
                                text: ""
                                color: Colors.outline
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Constants.fontSizeMd
                            }

                            Text {
                                Layout.maximumWidth: 160
                                textFormat: Text.PlainText
                                text: (root.weather.reportLocation || "").toUpperCase()
                                elide: Text.ElideRight
                                color: Colors.surfaceVariantForeground
                                font.family: Constants.fontFamily
                                font.pixelSize: Constants.fontSizeSm
                                font.weight: Font.DemiBold
                                font.letterSpacing: 1
                            }

                            TapHandler {
                                onTapped: root.weather.startEditingLocation()
                            }
                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        // Search field; the clear affordance doubles as the
                        // spinner while a committed location is loading.
                        RowLayout {
                            visible: root.weather.editingLocation
                            spacing: Constants.spacingSm

                            TextField {
                                id: locationField

                                Layout.preferredWidth: 190
                                enabled: !root.weather.savingLocation
                                placeholderText: "Search city"
                                color: Colors.surfaceForeground
                                font.family: Constants.fontFamily
                                font.pixelSize: Constants.fontSizeSm

                                background: Rectangle {
                                    radius: Constants.buttonRadius
                                    color: Colors.surfaceContainer
                                    border.width: Constants.borderWidth
                                    border.color: Colors.surfaceContainerHighest
                                }

                                onTextChanged: {
                                    if (root.weather.editingLocation)
                                        root.weather.geocodeChanged(text)
                                }

                                Keys.onPressed: function(event) {
                                    if (event.key === Qt.Key_Escape) {
                                        root.weather.cancelEditingLocation()
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Down) {
                                        if (root.weather.suggestionIndex < root.weather.locationSuggestions.length - 1)
                                            root.weather.suggestionIndex++
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Up) {
                                        if (root.weather.suggestionIndex > 0)
                                            root.weather.suggestionIndex--
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        root.weather.commitLocation(text)
                                        event.accepted = true
                                    }
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                radius: Constants.buttonRadius
                                color: clearArea.containsMouse
                                    ? Colors.surfaceContainerHigh
                                    : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    textFormat: Text.PlainText
                                    text: root.weather.savingLocation ? "󰓢" : "✕"
                                    color: Colors.outline
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Constants.fontSizeSm

                                    RotationAnimator on rotation {
                                        running: root.weather.savingLocation
                                        from: 0
                                        to: 360
                                        duration: 800
                                        loops: Animation.Infinite
                                    }
                                }

                                MouseArea {
                                    id: clearArea

                                    anchors.fill: parent
                                    enabled: !root.weather.savingLocation
                                    hoverEnabled: true
                                    cursorShape: enabled
                                        ? Qt.PointingHandCursor
                                        : Qt.ArrowCursor
                                    onClicked: root.weather.clearLocation()
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            visible: !root.weather.editingLocation
                            spacing: Constants.spacingSm

                            Text {
                                Layout.fillWidth: true
                                textFormat: Text.PlainText
                                text: root.weather.updatedAt.length > 0
                                    ? "UPDATED " + root.weather.updatedAt
                                    : ""
                                elide: Text.ElideRight
                                color: Colors.outline
                                font.family: Constants.fontFamily
                                font.pixelSize: Constants.fontSizeXs
                            }

                            // Manual refresh: the panel is a read-out of two
                            // APIs, and "is this right?" needs an answer now, not
                            // after the next auto-refresh.
                            Rectangle {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                radius: Constants.buttonRadius
                                color: refreshArea.containsMouse
                                    ? Colors.surfaceContainerHigh
                                    : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰑐"
                                    color: Colors.outline
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Constants.fontSizeSm

                                    RotationAnimator on rotation {
                                        running: root.weather.busy
                                        from: 0
                                        to: 360
                                        duration: 900
                                        loops: Animation.Infinite
                                    }
                                }

                                MouseArea {
                                    id: refreshArea

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.weather.refresh()
                                }
                            }
                        }

                        RowLayout {
                            visible: !!root.weather.current
                            spacing: Constants.spacingXl

                            component Stat: ColumnLayout {
                                id: stat

                                property string label: ""
                                property string value: ""

                                spacing: Constants.spacingXs

                                Text {
                                    text: stat.label
                                    color: Colors.outline
                                    font.family: Constants.fontFamily
                                    font.pixelSize: Constants.fontSizeXs
                                    font.weight: Font.DemiBold
                                    font.letterSpacing: 1
                                }

                                Text {
                                    textFormat: Text.PlainText
                                    text: stat.value
                                    color: Colors.surfaceForeground
                                    font.family: Constants.fontFamily
                                    font.pixelSize: Constants.fontSizeMd
                                    font.weight: Font.Medium
                                }
                            }

                            Stat {
                                label: "FEELS"
                                value: root.weather.reportFeels
                            }

                            Stat {
                                label: "WIND"
                                value: root.weather.reportWind
                            }

                            Stat {
                                label: "HUMID"
                                value: root.weather.reportHumidity
                            }
                        }
                    }
                }

                // ---------- Geocoding suggestions ----------
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: root.weather.editingLocation
                        && !root.weather.savingLocation
                        && root.weather.locationSuggestions.length > 0
                    spacing: 0

                    Repeater {
                        model: root.weather.locationSuggestions

                        Rectangle {
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            implicitHeight: suggestionRow.implicitHeight + Constants.paddingMd * 2
                            radius: Constants.buttonRadius
                            color: index === root.weather.suggestionIndex
                                ? Tokens.withAlpha(Colors.primary, 0.16)
                                : "transparent"

                            RowLayout {
                                id: suggestionRow

                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: Constants.paddingMd
                                anchors.rightMargin: Constants.paddingMd
                                spacing: Constants.spacingSm

                                Text {
                                    textFormat: Text.PlainText
                                    text: modelData.name
                                    color: Colors.surfaceForeground
                                    font.family: Constants.fontFamily
                                    font.pixelSize: Constants.fontSizeSm
                                    font.weight: Font.Medium
                                }

                                Text {
                                    Layout.fillWidth: true
                                    textFormat: Text.PlainText
                                    visible: text !== ""
                                    text: modelData.description
                                    elide: Text.ElideRight
                                    color: Colors.outline
                                    font.family: Constants.fontFamily
                                    font.pixelSize: Constants.fontSizeXs
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onPositionChanged: root.weather.suggestionIndex = index
                                onClicked: root.weather.pickSuggestion(modelData)
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: !root.weather.current
                    text: "Fetching forecast…"
                    color: Colors.outline
                    font.family: Constants.fontFamily
                    font.pixelSize: Constants.fontSizeSm
                    font.italic: true
                    textFormat: Text.PlainText
                }

                // ---------- separator before the forecast ----------
                Rule {
                    visible: !!root.weather.todayForecast
                        || root.weather.todayHourlyForecast.length > 0
                        || root.weather.forecastTimeline.length > 0
                }

                // ---------- Today, hour by hour ----------
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: root.weather.todayHourlyForecast.length > 0
                    spacing: Constants.spacingSm

                    Flickable {
                        id: hourly

                        Layout.fillWidth: true
                        Layout.preferredHeight: hourlyRow.implicitHeight
                        contentWidth: Math.max(width, hourlyRow.implicitWidth)
                        contentHeight: height
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        // Scrolls by drag, like the activity strip below it, and
                        // deliberately without a scrollbar: the strip is wider
                        // than the panel on purpose, and a permanent bar read as
                        // a control rather than a hint.
                        flickableDirection: Flickable.HorizontalFlick
                        interactive: contentWidth > width

                        RowLayout {
                            id: hourlyRow

                            spacing: Constants.spacingSm

                            Repeater {
                                model: root.weather.todayHourlyForecast

                                ColumnLayout {
                                    required property var modelData

                                    Layout.preferredWidth: 46
                                    spacing: Constants.spacingXs

                                    Text {
                                        Layout.fillWidth: true
                                        textFormat: Text.PlainText
                                        text: WeatherLabels.hourlyTime(modelData)
                                        horizontalAlignment: Text.AlignHCenter
                                        color: Colors.outline
                                        font.family: Constants.fontFamily
                                        font.pixelSize: Constants.fontSizeXs
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        textFormat: Text.PlainText
                                        text: WeatherLabels.iconForOpenMeteoCode(
                                            modelData.openMeteoWeatherCode, Number(modelData.isDay) === 0)
                                        horizontalAlignment: Text.AlignHCenter
                                        color: Colors.surfaceForeground
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Constants.fontSizeMd
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        textFormat: Text.PlainText
                                        text: WeatherLabels.hourlyTemperature(modelData, root.weather.useImperial)
                                        horizontalAlignment: Text.AlignHCenter
                                        color: Colors.surfaceForeground
                                        font.family: Constants.fontFamily
                                        font.pixelSize: Constants.fontSizeSm
                                    }
                                }
                            }

                            // Trailing space so the last hour scrolls fully into
                            // view instead of stopping half-clipped.
                            Item {
                                Layout.preferredWidth: Constants.spacingLg
                                Layout.preferredHeight: 1
                            }
                        }
                    }
                }

                // is the only block that needs separating from the hours above
                // it. Every section here does not.
                Rule {
                    visible: root.weather.forecastTimeline.length > 0
                }

                // ---------- Day by day ----------
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: root.weather.forecastTimeline.length > 0
                    spacing: Constants.spacingSm

                    SectionLabel {
                        text: "FORECAST"
                    }

                    Repeater {
                        model: root.weather.forecastTimeline

                        // Row plus its own rule: a separator anchored inside a
                        // managed item is undefined behaviour, so the rule is a
                        // sibling rather than a child of the row.
                        RowLayout {
                            id: forecastRow

                            required property var modelData
                            required property int index

                            readonly property string label: WeatherLabels.forecastDayLabel(
                                modelData.date, root.weather.today)
                            readonly property bool detailed: WeatherLabels.showDailyDetails(
                                modelData.date, root.weather.today)

                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            spacing: Constants.spacingSm

                            Text {
                                Layout.preferredWidth: 90
                                textFormat: Text.PlainText
                                text: forecastRow.label
                                elide: Text.ElideRight
                                color: Colors.surfaceForeground
                                font.family: Constants.fontFamily
                                font.pixelSize: Constants.fontSizeSm
                                font.weight: Font.DemiBold
                            }

                            Text {
                                Layout.preferredWidth: 58
                                Layout.alignment: Qt.AlignVCenter
                                visible: forecastRow.detailed
                                textFormat: Text.PlainText
                                text: forecastRow.detailed
                                    ? (WeatherLabels.forecastPrecipitation(forecastRow.modelData) || "—")
                                    : ""
                                horizontalAlignment: Text.AlignHCenter
                                color: Colors.surfaceVariantForeground
                                font.family: Constants.fontFamily
                                font.pixelSize: Constants.fontSizeXs
                            }

                            Text {
                                Layout.preferredWidth: 22
                                Layout.alignment: Qt.AlignVCenter
                                visible: forecastRow.detailed
                                textFormat: Text.PlainText
                                text: forecastRow.detailed
                                    ? WeatherLabels.iconForOpenMeteoCode(forecastRow.modelData.openMeteoWeatherCode, false)
                                    : ""
                                horizontalAlignment: Text.AlignHCenter
                                color: Colors.surfaceForeground
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Constants.fontSizeMd
                            }

                            Text {
                                Layout.preferredWidth: 22
                                Layout.alignment: Qt.AlignVCenter
                                visible: forecastRow.detailed
                                textFormat: Text.PlainText
                                text: forecastRow.detailed
                                    ? WeatherLabels.iconForOpenMeteoCode(forecastRow.modelData.openMeteoWeatherCode, true)
                                    : ""
                                horizontalAlignment: Text.AlignHCenter
                                opacity: 0.7
                                color: Colors.surfaceForeground
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Constants.fontSizeMd
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                            }

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                textFormat: Text.PlainText
                                text: WeatherLabels.bareTempForDay(forecastRow.modelData, "max", root.weather.useImperial)
                                    + " / "
                                    + WeatherLabels.bareTempForDay(forecastRow.modelData, "min", root.weather.useImperial)
                                horizontalAlignment: Text.AlignRight
                                color: Colors.surfaceForeground
                                font.family: Constants.fontFamily
                                font.pixelSize: Constants.fontSizeSm
                            }
                        }
                    }
                }


                // ---------- separator between forecast and activities ----------
                Rule {
                    visible: root.weather.activities.length > 0
                }

                // ---------- Activity forecasts ----------
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: root.weather.activities.length > 0
                    spacing: Constants.spacingSm

                    SectionLabel {
                        text: "ACTIVITY FORECASTS"
                    }

                    Flickable {
                        id: activityStrip

                        Layout.fillWidth: true
                        Layout.preferredHeight: 62
                        contentWidth: Math.max(width, activityRow.implicitWidth)
                        contentHeight: height
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        flickableDirection: Flickable.HorizontalFlick
                        interactive: contentWidth > width

                        RowLayout {
                            id: activityRow

                            spacing: Constants.spacingSm

                            Repeater {
                                model: root.weather.activities

                                Rectangle {
                                    required property var modelData

                                    readonly property bool good: modelData.status === "Good"

                                    Layout.preferredWidth: 132
                                    Layout.preferredHeight: 62
                                    radius: Constants.buttonRadius
                                    color: Tokens.withAlpha(Colors.surfaceContainer, 1)
                                    border.width: Constants.borderWidth
                                    border.color: good
                                        ? Tokens.withAlpha(Colors.primary, 0.45)
                                        : Colors.surfaceContainerHighest

                                    ColumnLayout {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.leftMargin: Constants.paddingMd
                                        anchors.rightMargin: Constants.paddingMd
                                        spacing: Constants.spacingXs

                                        Text {
                                            Layout.fillWidth: true
                                            textFormat: Text.PlainText
                                            text: modelData.name
                                            elide: Text.ElideRight
                                            color: Colors.surfaceForeground
                                            font.family: Constants.fontFamily
                                            font.pixelSize: Constants.fontSizeSm
                                            font.weight: Font.DemiBold
                                        }

                                        Text {
                                            textFormat: Text.PlainText
                                            text: modelData.status
                                            color: good ? Colors.primary : Colors.outline
                                            font.family: Constants.fontFamily
                                            font.pixelSize: Constants.fontSizeXs
                                            font.weight: Font.DemiBold
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            textFormat: Text.PlainText
                                            text: modelData.message
                                            elide: Text.ElideRight
                                            color: Colors.outline
                                            font.family: Constants.fontFamily
                                            font.pixelSize: Constants.fontSizeXs
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // The panel owns the field, so the facade's editing flag is what drives
    // seeding and focusing it.
    function syncEditingFocus() {
        if (weather && weather.editingLocation) {
            locationField.text = weather.configuredLocation
            locationField.selectAll()
            locationField.forceActiveFocus()
        }
    }

    // The facade exists before the bar's window is built, but the connection
    // waits for it so a reload cannot leave a dangling signal handler.
    Timer {
        interval: 300
        running: true
        repeat: false
        onTriggered: {
            if (!root.weather)
                return
            root.weather.editingLocationChanged.connect(root.syncEditingFocus)
            root.syncEditingFocus()
        }
    }

    Component.onDestruction: {
        if (root.weather)
            root.weather.editingLocationChanged.disconnect(root.syncEditingFocus)
    }
}
