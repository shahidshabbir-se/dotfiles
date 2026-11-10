pragma ComponentBehavior: Bound

import QtQuick
import qs.Commons as Commons
import qs.Ui as Ui
import qs.services

// One ordered section of the bar. Every entry becomes a Loader so widget
// options can be applied to the freshly loaded widget, and an unknown plugin id
// stays visible instead of collapsing into an empty gap.
Row {
    id: root

    property string section: ""
    property var entries: []
    property var registry: null
    property var barWindow: null
    property var barScreen: null

    spacing: Commons.Style.spacingSm

    Repeater {
        model: root.entries

        delegate: Item {
            id: delegate

            required property var modelData

            readonly property var entry: delegate.modelData || ({})
            readonly property Component entryComponent: root.registry
                ? root.registry.entryFor(delegate.entry.id)
                : null

            implicitWidth: loader.item ? loader.implicitWidth : errorWidget.implicitWidth
            implicitHeight: Commons.Style.barHeight

            Loader {
                id: loader

                anchors.centerIn: parent
                sourceComponent: delegate.entryComponent

                onLoaded: {
                    if (!item)
                        return;

                    Config.applyOptions(item, delegate.entry, function (option) {
                        console.warn("bar: widget '" + delegate.entry.id
                            + "' has no option '" + option + "'");
                    });

                    if ("parentWindow" in item)
                        item.parentWindow = root.barWindow;
                    if ("barWindow" in item)
                        item.barWindow = root.barWindow;
                    if ("barScreen" in item)
                        item.barScreen = root.barScreen;
                }
            }

            Ui.BarWidget {
                id: errorWidget

                anchors.centerIn: parent
                visible: !loader.item

                Text {
                    anchors.centerIn: parent
                    color: Commons.Color.red
                    text: "? " + (delegate.entry.id || "missing id") + " ?"
                    font {
                        family: Commons.Style.monoFontFamily
                        pixelSize: Commons.Style.fontSizeSm
                        weight: Font.Bold
                    }
                }
            }

            Component.onCompleted: {
                if (!delegate.entryComponent) {
                    console.error("bar: unknown plugin id '" + delegate.entry.id
                        + "' in section '" + root.section + "'");
                }
            }
        }
    }
}
