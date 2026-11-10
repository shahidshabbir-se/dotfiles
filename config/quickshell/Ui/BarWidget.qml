import QtQuick
import qs.Commons as Commons

Item {
    id: root

    default property alias content: row.data

    implicitWidth: row.implicitWidth + Commons.Style.spacingLg * 2
    implicitHeight: Commons.Style.barHeight

    Row {
        id: row

        anchors.verticalCenter: parent.verticalCenter
        x: Commons.Style.spacingLg
        spacing: Commons.Style.spacingSm
    }
}
