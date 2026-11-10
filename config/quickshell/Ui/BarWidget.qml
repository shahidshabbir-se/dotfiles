import QtQuick
import qs.Commons as Commons

// A row-shaped bar cell. Keeping this a Row (rather than an Item with an
// anchored inner Row) lets it nest inside BarSection and centerGroup without
// Qt warning about anchors inside a positioner.
Row {
    id: root

    height: Commons.Style.barHeight
    spacing: Commons.Style.spacingSm
    leftPadding: Commons.Style.spacingLg
    rightPadding: Commons.Style.spacingLg
}
