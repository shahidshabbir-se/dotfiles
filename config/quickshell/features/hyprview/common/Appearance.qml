import QtQuick
import qs.shared.theme

QtObject {
    id: m3

    readonly property color m3Primary: Colors.primary
    readonly property color m3OnPrimary: Colors.primaryForeground

    readonly property color m3PrimaryContainer: Colors.primaryContainer
    readonly property color m3OnPrimaryContainer: Colors.primaryContainerForeground

    readonly property color m3Secondary: Colors.secondary
    readonly property color m3OnSecondary: Colors.secondaryForeground

    readonly property color m3SecondaryContainer: Colors.secondaryContainer
    readonly property color m3OnSecondaryContainer: Colors.secondaryContainerForeground
}
