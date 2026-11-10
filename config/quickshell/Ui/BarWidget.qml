import QtQuick
import "../Commons"

Item {
    id: root

    default property alias content: row.data

    implicitWidth: row.implicitWidth + Style.spacingLg * 2
    implicitHeight: Style.barHeight

    Row {
        id: row

        anchors.centerIn: parent
        spacing: Style.spacingSm
    }
}
